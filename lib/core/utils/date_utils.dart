/// Normalize a [DateTime] to midnight (strips time components).
/// Always uses local time — no UTC conversion.
DateTime normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
