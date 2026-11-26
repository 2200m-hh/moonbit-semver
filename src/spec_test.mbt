// Spec-conformance tests for Semantic Versioning 2.0.0 (https://semver.org/).
//
// These tests are derived directly from the specification rather than from the
// implementation, so they can catch a bug that the implementation and an
// implementation-derived test would share.

fn cmp_text(a : String, b : String) -> Int {
  @moonbit-semver.compare_text(a, b).unwrap()
}

test "official SemVer precedence chain" {
  // The ordering example given verbatim in section 11 of the specification.
  let chain = [
    "1.0.0-alpha",
    "1.0.0-alpha.1",
    "1.0.0-alpha.beta",
    "1.0.0-beta",
    "1.0.0-beta.2",
    "1.0.0-beta.11",
    "1.0.0-rc.1",
    "1.0.0",
  ]
  for i = 0; i < chain.length() - 1; i = i + 1 {
    assert_eq(cmp_text(chain[i], chain[i + 1]), -1)
    assert_eq(cmp_text(chain[i + 1], chain[i]), 1)
  }
}

test "compare is reflexive antisymmetric and transitive" {
  // Strictly increasing, so each element's position predicts every result.
  let ordered = [
    "1.0.0-alpha",
    "1.0.0-alpha.1",
    "1.0.0-alpha.beta",
    "1.0.0-beta",
    "1.0.0-beta.2",
    "1.0.0-beta.11",
    "1.0.0-rc.1",
    "1.0.0",
    "1.0.1",
    "1.1.0",
    "2.0.0",
    "10.0.0",
  ]
  let n = ordered.length()
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      let ij = cmp_text(ordered[i], ordered[j])
      let ji = cmp_text(ordered[j], ordered[i])
      // Antisymmetry: compare(a, b) == -compare(b, a).
      assert_eq(ij, -ji)
      let expected = if i < j { -1 } else if i > j { 1 } else { 0 }
      assert_eq(ij, expected)
      for k = 0; k < n; k = k + 1 {
        let jk = cmp_text(ordered[j], ordered[k])
        let ik = cmp_text(ordered[i], ordered[k])
        // Transitivity: a < b and b < c implies a < c.
        if ij < 0 && jk < 0 {
          assert_true(ik < 0)
        }
        if ij == 0 && jk == 0 {
          assert_eq(ik, 0)
        }
      }
    }
  }
}

test "accepts valid edge cases" {
  let valid = [
    "0.0.0",
    "0.0.0-0",
    "0.0.0+0",
    "1.0.0-alpha",
    "1.0.0-0",
    "1.0.0-0.0",
    "1.0.0-a-b",
    "1.0.0--",
    "1.0.0-a--b",
    "1.0.0+01",
    "1.0.0+build-01",
    "1.0.0+build.01-x",
    "1.0.0-ALPHA",
    "1.0.0-Alpha",
    "1.0.0-alpha.0",
    "1.0.0-0a",
    "1.0.0-a0",
    "1.0.0-00a",
    "1.0.0-x.y.z",
    "1.0.0-alpha+001",
    "999999999999999999999999.0.0",
  ]
  for i = 0; i < valid.length(); i = i + 1 {
    assert_true(@moonbit-semver.is_valid(valid[i]))
  }
}

test "rejects invalid inputs" {
  let invalid = [
    "",
    "1",
    "1.2",
    "1.2.3.4",
    "01.2.3",
    "1.02.3",
    "1.2.03",
    "1.2.3-",
    "1.2.3+",
    "1.2.3-alpha..1",
    "1.2.3-alpha.01",
    "1.2.3-alpha.",
    "1.2.3-.alpha",
    "1.2.3+.",
    "1.2.3+a..b",
    "v1.2.3",
    " 1.2.3",
    "1.2.3 ",
    "1.2.3\n",
    "=1.2.3",
    "1.2.3-alpha_1",
    "1.2.3-alpha!",
    "1.2.3-a.b.c!",
    "1.2.3+build_1",
    "a.b.c",
    "-1.2.3",
    "1.-2.3",
    "1.2.-3",
    "1.2.3-00",
    "1.2.3-alpha+build+extra",
  ]
  for i = 0; i < invalid.length(); i = i + 1 {
    assert_false(@moonbit-semver.is_valid(invalid[i]))
  }
}

test "non-ASCII identifiers are rejected" {
  // Identifier characters are restricted to ASCII alphanumerics and hyphen.
  // These inputs also exercise substring index arithmetic around non-ASCII
  // characters.
  let invalid = [
    "1.2.3-α",
    "1.2.3-版本",
    "1.2.3-a.b.c.é",
    "1.2.3+构建",
    "版本.1.2",
  ]
  for i = 0; i < invalid.length(); i = i + 1 {
    assert_false(@moonbit-semver.is_valid(invalid[i]))
  }
}

test "identifier ordering follows ASCII sort order" {
  // Numeric identifiers always have lower precedence than alphanumeric ones.
  assert_eq(cmp_text("1.0.0-1", "1.0.0-a"), -1)
  assert_eq(cmp_text("1.0.0-a.1", "1.0.0-a.b"), -1)
  // Numeric identifiers are compared numerically, not lexically.
  assert_eq(cmp_text("1.0.0-2", "1.0.0-10"), -1)
  assert_eq(cmp_text("1.0.0-10", "1.0.0-2"), 1)
  // Alphanumeric identifiers are compared in ASCII sort order, so uppercase
  // precedes lowercase and hyphen precedes every alphanumeric.
  assert_eq(cmp_text("1.0.0-Alpha", "1.0.0-alpha"), -1)
  assert_eq(cmp_text("1.0.0-a", "1.0.0-A"), 1)
  assert_eq(cmp_text("1.0.0-a-b", "1.0.0-ab"), -1)
  assert_eq(cmp_text("1.0.0-alpha", "1.0.0-beta"), -1)
  // A larger set of fields has higher precedence when the prefix is equal.
  assert_eq(cmp_text("1.0.0-a", "1.0.0-a.1"), -1)
  assert_eq(cmp_text("1.0.0-1", "1.0.0-1.0"), -1)
  // Major, minor and patch are compared numerically regardless of digit count.
  assert_eq(cmp_text("1.0.0", "1.0.0"), 0)
  assert_eq(cmp_text("2.0.0", "10.0.0"), -1)
  assert_eq(cmp_text("1.9.0", "1.10.0"), -1)
}

test "build metadata never affects precedence" {
  let bases = ["1.0.0", "1.0.0-alpha", "2.3.4", "0.0.1-rc.1"]
  let builds = ["", "+build", "+001", "+build.1", "+a-b.c-d"]
  for i = 0; i < bases.length(); i = i + 1 {
    let base = bases[i]
    for j = 0; j < builds.length(); j = j + 1 {
      for k = 0; k < builds.length(); k = k + 1 {
        assert_eq(cmp_text(base + builds[j], base + builds[k]), 0)
      }
    }
  }

  // Precedence equality is not structural equality: build metadata is ignored
  // by compare, but it is part of the derived Eq instance.
  let with_a = @moonbit-semver.parse("1.0.0+build.1").unwrap()
  let with_b = @moonbit-semver.parse("1.0.0+build.2").unwrap()
  assert_eq(@moonbit-semver.compare(with_a, with_b), 0)
  assert_false(with_a == with_b)
  let same = @moonbit-semver.parse("1.0.0+build.1").unwrap()
  assert_true(with_a == same)
}

test "to_string round-trips canonical input" {
  let inputs = [
    "1.0.0",
    "1.2.3",
    "1.0.0-alpha",
    "1.0.0-alpha.1",
    "1.0.0-alpha.beta",
    "1.0.0-beta",
    "1.0.0-beta.2",
    "1.0.0-beta.11",
    "1.0.0-rc.1",
    "1.0.0+build.1",
    "1.0.0-alpha+build.1",
    "0.0.0",
    "0.1.0",
    "1.0.0+01",
    "1.0.0+build-01",
    "1.0.0--",
    "1.0.0-a--b",
    "99999999999999999999999999999999999999.0.0",
    "1.0.0-0",
    "1.0.0-0.0",
    "1.0.0-x.y.z",
  ]
  for i = 0; i < inputs.length(); i = i + 1 {
    let v = @moonbit-semver.parse(inputs[i]).unwrap()
    assert_eq(@moonbit-semver.to_string(v), inputs[i])
  }
}

test "errors name the offending input" {
  // Error messages should be actionable: they include the offending fragment
  // so a caller can point at the problem without re-parsing the string.
  assert_eq(
    @moonbit-semver.parse("1.2.3-alpha_1"),
    Err("invalid character in identifier: alpha_1"),
  )
  assert_eq(
    @moonbit-semver.parse("1.2"),
    Err("version core must have exactly three parts, got: 1.2"),
  )
  assert_eq(
    @moonbit-semver.parse("1.2.3-alpha..1"),
    Err("empty identifier in: alpha..1"),
  )
  assert_eq(
    @moonbit-semver.parse("1.2.3-alpha.01"),
    Err("numeric identifier must not contain leading zeros: 01"),
  )
  assert_eq(
    @moonbit-semver.compare_text("1.2", "1.0.0"),
    Err("left: version core must have exactly three parts, got: 1.2"),
  )
}

test "non-ASCII before a separator keeps error fragments intact" {
  // `find` locates separators and `unsafe_substring` slices by UTF-16 code
  // unit. A supplementary-plane character before '-' or '+' must not cause a
  // surrogate pair to be cut in half, and the reported fragment must be whole.
  assert_eq(
    @moonbit-semver.parse("1.2.3-😀+build"),
    Err("invalid character in identifier: 😀"),
  )
  assert_eq(
    @moonbit-semver.parse("1.2.3-😀.beta+build"),
    Err("invalid character in identifier: 😀"),
  )
  assert_eq(
    @moonbit-semver.parse("1.2.3-a+😀"),
    Err("invalid character in identifier: 😀"),
  )
  assert_eq(
    @moonbit-semver.parse("1.2.3+build-😀"),
    Err("invalid character in identifier: build-😀"),
  )
  assert_eq(
    @moonbit-semver.parse("😀.2.3+build"),
    Err("not a decimal number: 😀"),
  )
}

test "numeric identifiers rank below alphanumeric ones" {
  // Spec item 11.4.3: numeric identifiers always have lower precedence than
  // alphanumeric ones, even when the alphanumeric part starts with '-'.
  assert_eq(cmp_text("1.0.0-0", "1.0.0--"), -1)
  assert_eq(cmp_text("1.0.0-1", "1.0.0-a"), -1)
  assert_eq(cmp_text("1.0.0-999", "1.0.0-Z"), -1)
  assert_eq(cmp_text("1.0.0--", "1.0.0-0"), 1)
  // Among alphanumeric identifiers, ASCII order applies: '-' (45) < uppercase
  // (65-90) < lowercase (97-122).
  assert_eq(cmp_text("1.0.0--", "1.0.0-A"), -1)
  assert_eq(cmp_text("1.0.0-A", "1.0.0-a"), -1)
}
