// A small, dependency-free implementation of Semantic Versioning 2.0.0.
//
// Design goals:
//   - no external packages, so the project is easy to audit and reproduce;
//   - strict validation of numeric identifiers and leading zeros;
//   - precedence exactly follows the SemVer 2.0.0 specification;
//   - build metadata is preserved but ignored when comparing versions.

// Numeric components are stored as canonical decimal strings, not Int.
// SemVer 2.0.0 puts no upper bound on numeric identifiers, so parsing into a
// machine integer would silently overflow and corrupt comparison results for
// very large versions. Canonical strings (no leading zeros) compare correctly
// by length first, then lexicographically.
//
// Two notions of equality exist and must not be confused:
//   - `a == b` is structural equality: every field must match, including
//     build metadata.
//   - `compare(a, b) == 0` is SemVer precedence equality: build metadata is
//     ignored, as required by the specification.
#derive(Eq, Debug)
pub(all) struct Version {
  major : String
  minor : String
  patch : String
  pre : Array[String]
  build : Array[String]
}

fn split_char(text : String, sep : Char) -> Array[String] {
  let parts : Array[String] = []
  let mut start = 0
  // `iter2`'s index counts characters, but `unsafe_substring` and `length()`
  // work in UTF-16 code units. Mixing the two cuts supplementary-plane
  // characters (emoji, etc.) into lone surrogates. Iterate in code-unit space
  // instead. The separator must be a BMP character; this module only uses '.'.
  let sep_code = sep.to_int()
  for index = 0; index < text.length(); index = index + 1 {
    if text.unsafe_get(index).to_int() == sep_code {
      parts.push(text.unsafe_substring(start=start, end=index))
      start = index + 1
    }
  }
  parts.push(text.unsafe_substring(start=start, end=text.length()))
  parts
}

fn join_with(values : Array[String], sep : String) -> String {
  let mut out = ""
  for index = 0; index < values.length(); index = index + 1 {
    if index > 0 {
      out = out + sep
    }
    out = out + values[index]
  }
  out
}

fn is_ident_char(ch : Char) -> Bool {
  let c = ch.to_int()
  c == 45 || (c >= 48 && c <= 57) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122)
}

fn parse_uint(text : String) -> Result[String, String] {
  if text.length() == 0 {
    return Err("empty numeric identifier")
  }
  if text.length() > 1 && text.has_prefix("0") {
    return Err("numeric identifier must not contain leading zeros: " + text)
  }
  for _, ch in text {
    if !ch.is_ascii_digit() {
      return Err("not a decimal number: " + text)
    }
  }
  Ok(text)
}

// Compare two canonical decimal strings without overflow: longer means larger,
// equal length falls back to lexicographic order (digits only, no leading zeros).
fn cmp_number(a : String, b : String) -> Int {
  if a.length() < b.length() {
    -1
  } else if a.length() > b.length() {
    1
  } else {
    cmp_string(a, b)
  }
}

fn parse_identifiers(text : String, reject_leading_zero : Bool) -> Result[Array[String], String] {
  let parts = split_char(text, '.')
  let result : Array[String] = []
  for part in parts {
    if part.length() == 0 {
      return Err("empty identifier in: " + text)
    }
    let mut numeric = true
    for _, ch in part {
      if !is_ident_char(ch) {
        return Err("invalid character in identifier: " + part)
      }
      if !ch.is_ascii_digit() {
        numeric = false
      }
    }
    if reject_leading_zero && numeric && part.length() > 1 && part.has_prefix("0") {
      return Err("numeric identifier must not contain leading zeros: " + part)
    }
    result.push(part)
  }
  Ok(result)
}

/// Parse a SemVer 2.0.0 version string.
pub fn parse(input : String) -> Result[Version, String] {
  if input.length() == 0 {
    return Err("empty version string")
  }

  let mut core = input
  let mut build : Array[String] = []
  let mut pre : Array[String] = []

  match input.find("+") {
    Some(index) => {
      let metadata = input.unsafe_substring(start=index + 1, end=input.length())
      if metadata.length() == 0 {
        return Err("empty build metadata")
      }
      match parse_identifiers(metadata, false) {
        Ok(ids) => build = ids
        Err(e) => return Err(e)
      }
      core = input.unsafe_substring(start=0, end=index)
    }
    None => ()
  }

  match core.find("-") {
    Some(index) => {
      let prerelease = core.unsafe_substring(start=index + 1, end=core.length())
      if prerelease.length() == 0 {
        return Err("empty prerelease")
      }
      match parse_identifiers(prerelease, true) {
        Ok(ids) => pre = ids
        Err(e) => return Err(e)
      }
      core = core.unsafe_substring(start=0, end=index)
    }
    None => ()
  }

  let nums = split_char(core, '.')
  if nums.length() != 3 {
    return Err("version core must have exactly three parts, got: " + core)
  }
  let major = match parse_uint(nums[0]) {
    Ok(n) => n
    Err(e) => return Err(e)
  }
  let minor = match parse_uint(nums[1]) {
    Ok(n) => n
    Err(e) => return Err(e)
  }
  let patch = match parse_uint(nums[2]) {
    Ok(n) => n
    Err(e) => return Err(e)
  }

  Ok(Version::{ major: major, minor: minor, patch: patch, pre: pre, build: build })
}

fn cmp_int(a : Int, b : Int) -> Int {
  if a < b {
    -1
  } else if a > b {
    1
  } else {
    0
  }
}

// Compare identifier strings in ASCII sort order, as SemVer 2.0.0 requires.
//
// This must NOT use the built-in String comparison operators. In MoonBit they
// order by length first and only fall back to code-unit order for equal
// lengths, which would rank "beta" before "alpha" and "rc" before "beta".
// That ordering is self-consistent, so the mistake is invisible to tests that
// are derived from the implementation rather than from the specification.
// Comparing code points element by element gives the required order and does
// not depend on the target backend.
fn cmp_string(a : String, b : String) -> Int {
  let a_chars = a.to_array()
  let b_chars = b.to_array()
  let a_len = a_chars.length()
  let b_len = b_chars.length()
  let n = if a_len < b_len { a_len } else { b_len }
  for index = 0; index < n; index = index + 1 {
    let ca = a_chars[index].to_int()
    let cb = b_chars[index].to_int()
    if ca < cb {
      return -1
    }
    if ca > cb {
      return 1
    }
  }
  cmp_int(a_len, b_len)
}

fn cmp_identifier(a : String, b : String) -> Int {
  let a_numeric = is_all_digits(a)
  let b_numeric = is_all_digits(b)
  if a_numeric && b_numeric {
    cmp_number(a, b)
  } else if a_numeric {
    -1
  } else if b_numeric {
    1
  } else {
    cmp_string(a, b)
  }
}

fn is_all_digits(text : String) -> Bool {
  if text.length() == 0 {
    return false
  }
  for _, ch in text {
    if !ch.is_ascii_digit() {
      return false
    }
  }
  true
}

fn cmp_pre(a : Array[String], b : Array[String]) -> Int {
  if a.length() == 0 && b.length() == 0 {
    return 0
  }
  if a.length() == 0 {
    return 1
  }
  if b.length() == 0 {
    return -1
  }
  let n = if a.length() < b.length() { a.length() } else { b.length() }
  for index = 0; index < n; index = index + 1 {
    let c = cmp_identifier(a[index], b[index])
    if c != 0 {
      return c
    }
  }
  cmp_int(a.length(), b.length())
}

/// Compare two versions according to SemVer precedence.
/// Returns -1 when a < b, 0 when a == b, and 1 when a > b.
/// Build metadata is ignored.
///
/// Precondition: both values should come from `parse`. The fields must be
/// canonical non-empty decimal strings and non-empty ASCII identifiers.
/// Directly constructed `Version` values are outside the supported contract.
pub fn compare(a : Version, b : Version) -> Int {
  let c1 = cmp_number(a.major, b.major)
  if c1 != 0 {
    return c1
  }
  let c2 = cmp_number(a.minor, b.minor)
  if c2 != 0 {
    return c2
  }
  let c3 = cmp_number(a.patch, b.patch)
  if c3 != 0 {
    return c3
  }
  cmp_pre(a.pre, b.pre)
}

/// Render a version back to its canonical string form.
///
/// Precondition: `v` should come from `parse`; directly constructed values
/// with non-canonical fields may render a string that `parse` would reject.
pub fn to_string(v : Version) -> String {
  let mut out = "\{v.major}.\{v.minor}.\{v.patch}"
  if v.pre.length() > 0 {
    out = out + "-" + join_with(v.pre, ".")
  }
  if v.build.length() > 0 {
    out = out + "+" + join_with(v.build, ".")
  }
  out
}

/// Return true when the input is a valid SemVer 2.0.0 version string.
pub fn is_valid(text : String) -> Bool {
  match parse(text) {
    Ok(_) => true
    Err(_) => false
  }
}

/// Parse two version strings and compare them directly.
/// Returns an error that names the offending side when either input is invalid.
pub fn compare_text(a : String, b : String) -> Result[Int, String] {
  let av = match parse(a) {
    Ok(v) => v
    Err(e) => return Err("left: " + e)
  }
  let bv = match parse(b) {
    Ok(v) => v
    Err(e) => return Err("right: " + e)
  }
  Ok(compare(av, bv))
}
