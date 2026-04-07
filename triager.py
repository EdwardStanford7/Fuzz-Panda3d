import argparse
import os
import shutil
import subprocess
import time


class Args(argparse.Namespace):
    target: str = ""
    crash_dir: str = ""
    output_dir: str = ""


def extract_summary(stderr: str) -> str | None:
    """Return only the ASAN 'SUMMARY:' line."""
    for line in stderr.splitlines():
        if line.startswith("SUMMARY: AddressSanitizer"):
            return line.strip()
    return None


def find_crash_dirs(crash_root: str) -> list[str]:
    crash_dirs: list[str] = []

    for current_root, dirnames, _filenames in os.walk(crash_root):
        if os.path.basename(current_root) == "crashes":
            crash_dirs.append(current_root)
            dirnames[:] = []

    return sorted(crash_dirs)


def find_crash_inputs(crash_root: str, crash_dirs: list[str]) -> list[tuple[str, str]]:
    crash_inputs: list[tuple[str, str]] = []
    for current_root in crash_dirs:
        filenames = os.listdir(current_root)
        for fname in sorted(filenames):
            if not fname.startswith("id:"):  # AFL crash naming pattern
                continue

            fpath = os.path.join(current_root, fname)
            display_path = os.path.relpath(fpath, crash_root)
            crash_inputs.append((display_path, fpath))

    return crash_inputs


def count_crash_files(crash_dir: str) -> int:
    return sum(1 for fname in os.listdir(crash_dir) if fname.startswith("id:"))


def write_crash_report(
    output_dir: str,
    crash_number: int,
    crash_path: str,
    stderr: str,
) -> None:
    crash_output_dir = os.path.join(output_dir, f"crash_{crash_number}")
    os.makedirs(crash_output_dir, exist_ok=True)

    repro_file = os.path.join(crash_output_dir, os.path.basename(crash_path))
    _ = shutil.copy2(crash_path, repro_file)

    report_file = os.path.join(crash_output_dir, "report.txt")
    with open(report_file, "w", encoding="utf-8") as f:
        _ = f.write(stderr)


def parse_args() -> Args:
    parser = argparse.ArgumentParser(description="Run a target against AFL crashes and summarize ASAN findings.")
    _ = parser.add_argument(
        "--target",
        dest="target",
        metavar="TARGET",
        required=True,
        help="Path to the target executable.",
    )
    _ = parser.add_argument(
        "--crash-dir",
        dest="crash_dir",
        metavar="CRASH_DIR",
        required=True,
        help="Directory containing crash inputs.",
    )
    _ = parser.add_argument(
        "--output-dir",
        dest="output_dir",
        metavar="OUTPUT_DIR",
        required=True,
        help="Output directory where crash reports and the summary file will be written.",
    )
    return parser.parse_args(namespace=Args())


def main() -> None:
    start_time = time.monotonic()
    args = parse_args()
    best_crashes: dict[str, tuple[int, str, str, str]] = {}
    total_crashes_triaged = 0
    crash_dirs = find_crash_dirs(args.crash_dir)
    crash_inputs = find_crash_inputs(args.crash_dir, crash_dirs)

    print(f"Found {len(crash_dirs)} crash directories.")

    current_crash_dir = ""
    for display_path, fpath in crash_inputs:
        crash_dir = os.path.dirname(fpath)
        if crash_dir != current_crash_dir:
            current_crash_dir = crash_dir
            relative_crash_dir = os.path.relpath(crash_dir, args.crash_dir)
            print(f"\n[>] Processing {relative_crash_dir} ({count_crash_files(crash_dir)} crash files)")

        print(f"[+] Running {fpath}")
        total_crashes_triaged += 1

        try:
            result = subprocess.run(
                [args.target, fpath],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                encoding="utf-8",
                errors="replace",
                timeout=5,
                check=False,
            )
        except subprocess.TimeoutExpired:
            print("Timeout, skipping...")
            continue

        summary = extract_summary(result.stderr)

        if summary:
            file_size = os.path.getsize(fpath)
            existing_crash = best_crashes.get(summary)

            if existing_crash is None:
                best_crashes[summary] = (file_size, display_path, fpath, result.stderr)
                print(f"{summary}")
            elif file_size < existing_crash[0]:
                best_crashes[summary] = (file_size, display_path, fpath, result.stderr)
                print(f"Smaller reproducer found ({file_size} bytes): {summary}")
            else:
                print(f"Duplicate crash, keeping smaller reproducer: {summary}")
        else:
            print("No ASAN summary found.")

    os.makedirs(args.output_dir, exist_ok=True)

    for crash_number, (_summary, (_file_size, _crash_name, crash_path, stderr)) in enumerate(
        sorted(best_crashes.items(), key=lambda item: item[1][0]),
        start=1,
    ):
        write_crash_report(args.output_dir, crash_number, crash_path, stderr)

    summary_file = os.path.join(args.output_dir, "summary")
    elapsed_seconds = time.monotonic() - start_time
    with open(summary_file, "w", encoding="utf-8") as f:
        _ = f.write(f"Ran for (seconds): {elapsed_seconds:.2f}\n")
        _ = f.write(f"Crash Directories: {len(crash_dirs)}\n")
        _ = f.write(f"Unique Crashes: {len(best_crashes)}\n")
        _ = f.write(f"Total Crashes: {total_crashes_triaged}\n")

    print("\nDone. Crash reports saved under:", args.output_dir)
    print("Summary saved to:", summary_file)
    print("\a", end="", flush=True)


if __name__ == "__main__":
    main()
