fn must_parse(text : String) -> @moonbit-semver.Version {
  @moonbit-semver.parse(text).unwrap()
}

test "parse simple version" {
  let v = must_parse("1.2.3")
  assert_eq(v.major, "1")
  assert_eq(v.minor, "2")
  assert_eq(v.patch, "3")
  assert_eq(v.pre.length(), 0)
  assert_eq(v.build.length(), 0)
}

test "parse prerelease and build metadata" {
  let v = must_parse("1.0.0-alpha.1+build.5")
  assert_eq(v.pre.length(), 2)
  assert_eq(v.pre[0], "alpha")
  assert_eq(v.pre[1], "1")
  assert_eq(v.build.length(), 2)
  assert_eq(v.build[0], "build")
  assert_eq(v.build[1], "5")
  assert_eq(@moonbit-semver.to_string(v), "1.0.0-alpha.1+build.5")
}

test "reject invalid versions" {
  assert_true(@moonbit-semver.parse("") is Err(_))
  assert_true(@moonbit-semver.parse("1.2") is Err(_))
  assert_true(@moonbit-semver.parse("1.2.3-") is Err(_))
  assert_true(@moonbit-semver.parse("1.2.3+") is Err(_))
  assert_true(@moonbit-semver.parse("01.2.3") is Err(_))
  assert_true(@moonbit-semver.parse("1.02.3") is Err(_))
  assert_true(@moonbit-semver.parse("1.2.3-alpha..1") is Err(_))
  assert_true(@moonbit-semver.parse("1.2.3-alpha_1") is Err(_))
  assert_true(@moonbit-semver.parse("1.2.3-alpha.01") is Err(_))
}

test "precedence basics" {
  assert_eq(@moonbit-semver.compare(must_parse("1.0.0"), must_parse("1.0.1")), -1)
  assert_eq(@moonbit-semver.compare(must_parse("2.0.0"), must_parse("1.99.99")), 1)
  assert_eq(@moonbit-semver.compare(must_parse("1.0.0+build.1"), must_parse("1.0.0+build.2")), 0)
}

test "SemVer prerelease precedence" {
  assert_eq(@moonbit-semver.compare(must_parse("1.0.0-alpha"), must_parse("1.0.0")), -1)
  assert_eq(@moonbit-semver.compare(must_parse("1.0.0-alpha.1"), must_parse("1.0.0-alpha.beta")), -1)
  assert_eq(@moonbit-semver.compare(must_parse("1.0.0-beta"), must_parse("1.0.0-beta.2")), -1)
  assert_eq(@moonbit-semver.compare(must_parse("1.0.0-beta.2"), must_parse("1.0.0-beta.11")), -1)
  assert_eq(@moonbit-semver.compare(must_parse("1.0.0-rc.1"), must_parse("1.0.0")), -1)
}

test "validity helper and build metadata leading zeros" {
  assert_true(@moonbit-semver.is_valid("1.2.3"))
  assert_true(@moonbit-semver.is_valid("1.0.0+01"))
  assert_false(@moonbit-semver.is_valid("01.2.3"))
  assert_false(@moonbit-semver.is_valid("1.0.0-alpha.01"))
  assert_false(@moonbit-semver.is_valid("1.0.0-α"))
}

test "compare_text reports the offending side" {
  assert_eq(@moonbit-semver.compare_text("1.0.0-alpha", "1.0.0").unwrap(), -1)
  assert_true(@moonbit-semver.compare_text("bad", "1.0.0") is Err(_))
  assert_true(@moonbit-semver.compare_text("1.0.0", "bad") is Err(_))
}

test "large numeric identifiers keep precedence" {
  assert_true(@moonbit-semver.is_valid("999999999999999999999.1.1"))
  assert_eq(
    @moonbit-semver.compare_text(
      "999999999999999999999.0.0",
      "1000000000000000000000.0.0",
    ).unwrap(),
    -1,
  )
}

test "numbers beyond Int range do not overflow" {
  let huge = "99999999999999999999999999999999999999.0.0"
  assert_true(@moonbit-semver.is_valid(huge))
  assert_eq(
    @moonbit-semver.compare_text(huge, "1.0.0").unwrap(),
    1,
  )
  assert_eq(
    @moonbit-semver.compare_text("1.0.0", huge).unwrap(),
    -1,
  )
  assert_eq(
    @moonbit-semver.compare_text(
      "1.0.0-99999999999999999999999999999999",
      "1.0.0-100000000000000000000000000000000",
    ).unwrap(),
    -1,
  )
}

test "splitting works in UTF-16 code unit space" {
  // A supplementary-plane character occupies two code units but one character.
  // Iterating by character index while slicing by code unit used to cut it in
  // half, producing a lone surrogate in the error fragment. The error must
  // now name the complete identifier.
  assert_eq(
    @moonbit-semver.parse("1.2.3-😀.beta"),
    Err("invalid character in identifier: 😀"),
  )
  assert_eq(
    @moonbit-semver.parse("1.2.3+build.😀"),
    Err("invalid character in identifier: 😀"),
  )
}

test "supplementary-plane characters are rejected cleanly" {
  assert_false(@moonbit-semver.is_valid("😀.2.3"))
  assert_false(@moonbit-semver.is_valid("1.😀.3"))
  assert_false(@moonbit-semver.is_valid("1.2.😀"))
  assert_false(@moonbit-semver.is_valid("1.2.3+😀"))
  assert_false(@moonbit-semver.is_valid("1.2.3-😀.beta"))
}

test "empty numeric fields are rejected" {
  assert_false(@moonbit-semver.is_valid("1..3"))
  assert_false(@moonbit-semver.is_valid(".2.3"))
  assert_false(@moonbit-semver.is_valid("1.2."))
}

test "multiple leading zeros are rejected" {
  assert_false(@moonbit-semver.is_valid("00.1.2"))
  assert_false(@moonbit-semver.is_valid("1.02.3"))
  assert_false(@moonbit-semver.is_valid("1.2.000"))
}

test "directly constructed Version is handled defensively" {
  // Outside the supported contract (values should come from parse), but an
  // empty identifier must no longer be treated as a numeric identifier.
  let a = @moonbit-semver.Version::{
    major: "1", minor: "0", patch: "0", pre: [""], build: [],
  }
  let b = @moonbit-semver.Version::{
    major: "1", minor: "0", patch: "0", pre: ["a"], build: [],
  }
  assert_eq(@moonbit-semver.compare(a, b), -1)
}
