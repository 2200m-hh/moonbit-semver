// A small, dependency-free implementation of Semantic Versioning 2.0.0.
//
// Design goals:
//   - no external packages, so the project is easy to audit and reproduce;
//   - strict validation of numeric identifiers and leading zeros;
//   - precedence exactly follows the SemVer 2.0.0 specification;
//   - build metadata is preserved but ignored when comparing versions.

pub(all) struct Version {
  major : Int
  minor : Int
  patch : Int
  pre : Array[String]
  build : Array[String]
}

fn split_char(text : String, sep : Char) -> Array[String] {
  let parts : Array[String] = []
  let mut start = 0
  for index, ch in text {
    if ch == sep {
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

fn parse_uint(text : String) -> Result[Int, String] {
  if text.length() == 0 {
    return Err("empty numeric identifier")
  }
  if text.length() > 1 && text.has_prefix("0") {
    return Err("numeric identifier must not contain leading zeros: " + text)
  }
  let mut value = 0
  for _, ch in text {
    if !ch.is_ascii_digit() {
      return Err("not a decimal number: " + text)
    }
    value = value * 10 + ch.to_int() - '0'.to_int()
  }
  Ok(value)
}

fn parse_identifiers(text : String, reject_leading_zero : Bool) -> Result[Array[String], String] {
  let parts = split_char(text, '.')
  let result : Array[String] = []
  for part in parts {
    if part.length() == 0 {
      return Err("empty identifier")
    }
    let mut numeric = true
    for _, ch in part {
      if !is_ident_char(ch) {
        return Err("invalid identifier character")
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
    return Err("version core must have exactly three parts")
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

fn cmp_string(a : String, b : String) -> Int {
  if a < b {
    -1
  } else if a > b {
    1
  } else {
    0
  }
}

fn cmp_identifier(a : String, b : String) -> Int {
  let a_numeric = is_all_digits(a)
  let b_numeric = is_all_digits(b)
  if a_numeric && b_numeric {
    let ai = parse_uint(a).unwrap()
    let bi = parse_uint(b).unwrap()
    cmp_int(ai, bi)
  } else if a_numeric {
    -1
  } else if b_numeric {
    1
  } else {
    cmp_string(a, b)
  }
}

fn is_all_digits(text : String) -> Bool {
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
pub fn compare(a : Version, b : Version) -> Int {
  let c1 = cmp_int(a.major, b.major)
  if c1 != 0 {
    return c1
  }
  let c2 = cmp_int(a.minor, b.minor)
  if c2 != 0 {
    return c2
  }
  let c3 = cmp_int(a.patch, b.patch)
  if c3 != 0 {
    return c3
  }
  cmp_pre(a.pre, b.pre)
}

/// Render a version back to its canonical string form.
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
