RSpec.describe Pronto::Formatter::GithubActionCheckRunFormatter do

  STUBBED_ENV = {
    GITHUB_SHA: 'abcd12',
    GITHUB_EVENT_PATH: File.expand_path('fixtures/event.json', __dir__),
  }.freeze

  around do |example|
    with_env STUBBED_ENV do
      example.run
    end
  end

  context 'when the runner is rubocop' do
    it 'posts a check run with annotations' do
      check_runs_url = "https://api.github.com/repos/Codertocat/Hello-World/check-runs"
      post_stub = stub_request(:post, check_runs_url).to_return(
        {status: 201, body: '{"id": 1}'},
        {status: 201, body: '{"id": 2}'},
      )
      allow(Pronto::Runner).to receive(:repository).and_return([Pronto::Rubocop])

      Dir.chdir('spec/fixtures/test.git') do
        Pronto::CLI.start(%w(run -f github_action_check_run))
      end

      expect(
        a_request(:post, "https://api.github.com/repos/Codertocat/Hello-World/check-runs").with do |request|
          data = JSON.parse(request.body)
          expect(data.dig('name')).to eq 'rubocop'
          expect(data.dig('output', 'summary')).to match(/There are 10 issues/)
          expect(data.dig('output', 'annotations').size).to eq 10
          expect(data.dig('status')).to eq 'completed'
          expect(data.dig('conclusion')).to eq 'failure'
          expect(data.dig('output', 'annotations')).to eq([
            {"annotation_level"=>"warning",
            "end_line"=>1,
            "message"=>"Style/FrozenStringLiteralComment: Missing frozen string literal comment.",
            "path"=>"main.rb",
            "start_line"=>1,
            "title"=>"rubocop"},
            {"annotation_level"=>"warning",
            "end_line"=>1,
            "message"=>"Layout/ExtraSpacing: Unnecessary spacing detected.",
            "path"=>"main.rb",
            "start_line"=>1,
            "title"=>"rubocop"},
            {"annotation_level"=>"warning",
            "end_line"=>1,
            "message"=>"Layout/SpaceBeforeFirstArg: Put one space between the method name and the first argument.",
            "path"=>"main.rb",
            "start_line"=>1,
            "title"=>"rubocop"},
            {"annotation_level"=>"warning",
            "end_line"=>3,
            "message"=>"Style/Documentation: Missing top-level documentation comment for `class My_Class`.",
            "path"=>"main.rb",
            "start_line"=>3,
            "title"=>"rubocop"},
            {"annotation_level"=>"warning",
            "end_line"=>3,
            "message"=>"Naming/ClassAndModuleCamelCase: Use CamelCase for classes and modules.",
            "path"=>"main.rb",
            "start_line"=>3,
            "title"=>"rubocop"},
            {"annotation_level"=>"warning",
            "end_line"=>4,
            "message"=>"Layout/IndentationWidth: Use 2 (not 4) spaces for indentation.",
            "path"=>"main.rb",
            "start_line"=>4,
            "title"=>"rubocop"},
            {"annotation_level"=>"warning",
            "end_line"=>4,
            "message"=>"Naming/MethodName: Use snake_case for method names.",
            "path"=>"main.rb",
            "start_line"=>4,
            "title"=>"rubocop"},
            {"annotation_level"=>"warning",
            "end_line"=>4,
            "message"=>"Style/DefWithParentheses: Omit the parentheses in defs when the method doesn't accept any arguments.",
            "path"=>"main.rb",
            "start_line"=>4,
            "title"=>"rubocop"},
            {"annotation_level"=>"warning",
            "end_line"=>5,
            "message"=>"Layout/IndentationWidth: Use 2 (not 4) spaces for indentation.",
            "path"=>"main.rb",
            "start_line"=>5,
            "title"=>"rubocop"},
            {"annotation_level"=>"warning",
            "end_line"=>6,
            "message"=>"Layout/DefEndAlignment: `end` at 6, 8 is not aligned with `def` at 4, 4.",
            "path"=>"main.rb",
            "start_line"=>6,
            "title"=>"rubocop"}
          ])
        end
      ).to have_been_made
    end
  end
  context 'when the runner is yamllint' do
    it 'posts a check run with annotations' do
      check_runs_url = "https://api.github.com/repos/Codertocat/Hello-World/check-runs"
      post_stub = stub_request(:post, check_runs_url).to_return(
        {status: 201, body: '{"id": 1}'},
        {status: 201, body: '{"id": 2}'},
      )
      allow(Pronto::Runner).to receive(:repository).and_return([Pronto::YAMLLint])

      Dir.chdir('spec/fixtures/test.git') do
        Pronto::CLI.start(%w(run -f github_action_check_run))
      end

      expect(
        a_request(:post, "https://api.github.com/repos/Codertocat/Hello-World/check-runs").with do |request|
          data = JSON.parse(request.body)
          expect(data.dig('name')).to eq 'yamllint_runner'
          expect(data.dig('output', 'summary')).to match(/There are 3 issues/)
          expect(data.dig('output', 'annotations').size).to eq 3
          expect(data.dig('status')).to eq 'completed'
          expect(data.dig('conclusion')).to eq 'failure'
          expect(data.dig('output', 'annotations')).to eq([
            {
              "annotation_level"=>"warning",
              "end_line"=>1,
              "message"=>"1:1: [warning] missing document start \"---\" (document-start)",
              "path"=>"main.yaml",
              "start_line"=>1,
              "title"=>"yamllint_runner"
            },
            {
              "annotation_level"=>"failure",
              "end_line"=>3,
              "message"=>"3:2: [error] wrong indentation: expected 2 but found 1 (indentation)",
              "path"=>"main.yaml",
              "start_line"=>3,
              "title"=>"yamllint_runner"
            },
            {
              "annotation_level"=>"failure",
              "end_line"=>4,
              "message"=>"4:3: [error] syntax error: expected <block end>, but found '<block mapping start>' (syntax)",
              "path"=>"main.yaml",
              "start_line"=>4,
              "title"=>"yamllint_runner"
            }
          ])
        end
      ).to have_been_made
    end
  end

  it 'posts a check run with text summary' do
    pending "when pronto-poper supports pronto ~> 0.11"
    check_runs_url = "https://api.github.com/repos/Codertocat/Hello-World/check-runs"
    post_stub = stub_request(:post, check_runs_url).to_return(
      {status: 201, body: '{"id": 1}'},
      {status: 201, body: '{"id": 2}'},
    )
    allow(Pronto::Runner).to receive(:repository).and_return([Pronto::Poper])

    Dir.chdir('spec/fixtures/test.git') do
      Pronto::CLI.start(%w(run -f github_action_check_run))
    end

    expect(
      a_request(:post, "https://api.github.com/repos/Codertocat/Hello-World/check-runs").with do |request|
        data = JSON.parse(request.body)
        expect(data.dig('name')).to eq 'poper'
        expect(data.dig('output', 'summary')).to match(/There are 2 issues/)
        # these messages aren't attributed to a line, so we put them in the Details section
        expect(data.dig('output', 'annotations').size).to eq 0
        expect(data.dig('status')).to eq 'completed'
        expect(data.dig('conclusion')).to eq 'failure'
        expect(data.dig('output', 'text')).to eq(<<~TXT)
          | sha | level | message |
          | --- | --- | --- |
          | `b00b0a8` | `warning` | Git commit message should start with a capital letter |
          | `7cb7f40` | `warning` | Git commit message should start with a capital letter |
        TXT
      end
    ).to have_been_made
  end

  def with_env(options, &block)
    ClimateControl.modify(options, &block)
  end

end
