fn show_pair(a_text : String, b_text : String) -> Unit {
  let a = @semver.parse(a_text).unwrap()
  let b = @semver.parse(b_text).unwrap()
  let order = @semver.compare(a, b)
  let symbol = if order < 0 { "<" } else if order > 0 { ">" } else { "==" }
  println("\{a_text}  \{symbol}  \{b_text}")
}

fn main {
  println("moonbit-semver demo")
  println("-------------------")
  show_pair("1.0.0-alpha", "1.0.0")
  show_pair("1.0.0-alpha.1", "1.0.0-alpha.beta")
  show_pair("1.0.0-beta.2", "1.0.0-beta.11")
  show_pair("1.0.0+build.1", "1.0.0+build.2")

  let v = @semver.parse("2.3.4-rc.1+sha.abc123").unwrap()
  println("parsed: \{@semver.to_string(v)}")
}
