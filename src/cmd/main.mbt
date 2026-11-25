fn show_pair(a_text : String, b_text : String) -> Unit {
  match @semver.compare_text(a_text, b_text) {
    Err(e) => println("error: " + e)
    Ok(order) => {
      let symbol = if order < 0 { "<" } else if order > 0 { ">" } else { "==" }
      println("\{a_text}  \{symbol}  \{b_text}")
    }
  }
}

fn main {
  let cmd = @argparse.Command(
    "semver",
    about="Compare two Semantic Versioning 2.0.0 strings.",
    version="0.1.0",
    positionals=[
      @argparse.PositionArg("left", about="Left version string", default_values=["1.0.0-alpha"]),
      @argparse.PositionArg("right", about="Right version string", default_values=["1.0.0"]),
    ],
  )
  let matches = cmd.parse()
  let left = matches.values.get("left").unwrap()[0]
  let right = matches.values.get("right").unwrap()[0]
  show_pair(left, right)
}
