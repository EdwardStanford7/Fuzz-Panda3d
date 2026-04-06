import argparse
import os
import subprocess
import time


class Args(argparse.Namespace):
    target: str = ""
    crash_dir: str = ""
    output_file: str = ""


def extract_summary(stderr: str) -> str | None:
    """Return only the ASAN 'SUMMARY:' line."""
    for line in stderr.splitlines():
        if line.startswith("SUMMARY: AddressSanitizer"):
            return line.strip()
    return None


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
        "--output-file",
        dest="output_file",
        metavar="OUTPUT_FILE",
        required=True,
        help="File to write summary counts to.",
    )
    return parser.parse_args(namespace=Args())


def main() -> None:
    start_time = time.monotonic()
    args = parse_args()
    seen_summaries: set[str] = set()
    unique_crashes: list[tuple[str, str]] = []
    total_crashes_triaged = 0

    for fname in os.listdir(args.crash_dir):
        if not fname.startswith("id:"):  # AFL crash naming pattern
            continue

        fpath = os.path.join(args.crash_dir, fname)
        print(f"[+] Running {fpath}")
        total_crashes_triaged += 1

        try:
            result = subprocess.run(
                [args.target, fpath],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=5,
                check=False,
            )
        except subprocess.TimeoutExpired:
            print("Timeout, skipping...")
            continue

        summary = extract_summary(result.stderr)

        if summary:
            if summary in seen_summaries:
                print(f"Duplicate crash, skipping: {summary}")
                continue

            seen_summaries.add(summary)
            unique_crashes.append((fname, summary))
            print(f"{summary}")
        else:
            print("No ASAN summary found.")

    output_dir = os.path.dirname(args.output_file)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    with open(args.output_file, "w", encoding="utf-8") as f:
        for crash_name, summary in unique_crashes:
            _ = f.write(f"{crash_name}: {summary}\n")

    summary_file = os.path.join(output_dir or ".", "summary")
    elapsed_seconds = time.monotonic() - start_time
    with open(summary_file, "w", encoding="utf-8") as f:
        _ = f.write(f"Ran for (seconds): {elapsed_seconds:.2f}\n")
        _ = f.write(f"Unique Crashes: {len(unique_crashes)}\n")
        _ = f.write(f"Total Crashes: {total_crashes_triaged}\n")

    print("\nDone. Results saved to:", args.output_file)
    print("Summary saved to:", summary_file)


if __name__ == "__main__":
    main()
