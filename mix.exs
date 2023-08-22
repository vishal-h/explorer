defmodule Explorer.MixProject do
  use Mix.Project

  @source_url "https://github.com/elixir-nx/explorer"
  @version "0.6.2-dev"
  @dev? String.ends_with?(@version, "-dev")
  @force_build? System.get_env("EXPLORER_BUILD") in ["1", "true"]

  def project do
    [
      app: :explorer,
      name: "Explorer",
      description:
        "Series (one-dimensional) and dataframes (two-dimensional) for fast data exploration in Elixir",
      version: @version,
      elixir: "~> 1.13",
      package: package(),
      deps: deps(),
      docs: docs(),
      preferred_cli_env: [ci: :test, "localstack.setup": :test],
      aliases: [
        "rust.lint": ["cmd cargo clippy --manifest-path=native/explorer/Cargo.toml -- -Dwarnings"],
        "rust.fmt": ["cmd cargo fmt --manifest-path=native/explorer/Cargo.toml --all"],
        "localstack.setup": ["cmd ./test/support/setup-localstack.sh"],
        ci: ["format", "rust.fmt", "rust.lint", "test"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl],
      env: [default_backend: Explorer.PolarsBackend]
    ]
  end

  defp deps do
    [
      {:aws_signature, "~> 0.3"},
      {:castore, "~> 1.0"},
      {:fss, github: "elixir-explorer/fss", branch: "main"},
      {:rustler_precompiled, "~> 0.6"},
      {:table, "~> 0.1.2"},
      {:adbc, "~> 0.1", optional: true},

      ## Optional
      {:rustler, "~> 0.29.0", optional: not (@dev? or @force_build?)},
      {:nx, "~> 0.4.0 or ~> 0.5.0", optional: true},

      ## Test
      {:bypass, "~> 2.1", only: :test},

      ## Dev
      {:ex_doc, "~> 0.24", only: :dev},
      {:benchee, "~> 1.1", only: :dev}
    ]
  end

  defp docs do
    [
      main: "Explorer",
      logo: "explorer-exdoc.png",
      source_ref: "v#{@version}",
      source_url: @source_url,
      groups_for_modules: [
        # Explorer,
        # Explorer.DataFrame,
        # Explorer.Datasets,
        # Explorer.Query,
        # Explorer.Series,
        # Explorer.TensorFrame,
        Backends: [
          Explorer.Backend,
          Explorer.Backend.DataFrame,
          Explorer.Backend.Series,
          Explorer.Backend.LazyFrame,
          Explorer.Backend.LazySeries,
          Explorer.PolarsBackend
        ]
      ],
      groups_for_functions: [
        "Functions: Conversion": &(&1[:type] == :conversion),
        "Functions: Single-table": &(&1[:type] == :single),
        "Functions: Multi-table": &(&1[:type] == :multi),
        "Functions: Row-based": &(&1[:type] == :rows),
        "Functions: Aggregation": &(&1[:type] == :aggregation),
        "Functions: Element-wise": &(&1[:type] == :element_wise),
        "Functions: Datetime ops": &(&1[:type] == :datetime_wise),
        "Functions: Float ops": &(&1[:type] == :float_wise),
        "Functions: String ops": &(&1[:type] == :string_wise),
        "Functions: Introspection": &(&1[:type] == :introspection),
        "Functions: IO": &(&1[:type] == :io),
        "Functions: Shape": &(&1[:type] == :shape),
        "Functions: Window": &(&1[:type] == :window)
      ],
      extras: ["notebooks/exploring_explorer.livemd", "CHANGELOG.md"],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "native",
        "datasets",
        "checksum-*.exs",
        "mix.exs",
        "README.md",
        "LICENSE"
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      maintainers: ["Christopher Grainger", "Philip Sampaio", "José Valim"]
    ]
  end
end
