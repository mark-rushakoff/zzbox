const std = @import("std");

/// Executes false.
/// Does not accept any arguments.
/// https://pubs.opengroup.org/onlinepubs/9799919799/utilities/false.html
pub fn execute(
    rng: anytype,
) u8 {
    // Exit status section of spec:
    // "The false utility shall always exit with a value between 1 and 125, inclusive."
    return rng.intRangeAtMost(u8, 1, 125);
}
