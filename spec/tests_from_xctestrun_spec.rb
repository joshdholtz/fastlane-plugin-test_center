describe Fastlane::Actions::TestsFromXctestrunAction do
  describe 'it handles invalid data' do
    it 'a failure occurs when a non-existent xctestrun file is specified' do
      fastfile = "lane :test do
        tests_from_xctestrun(
          xctestrun: 'path/to/non_existent.xctestrun'
        )
      end"
      expect { Fastlane::FastFile.new.parse(fastfile).runner.execute(:test) }.to(
        raise_error(FastlaneCore::Interface::FastlaneError) do |error|
          expect(error.message).to match("Error: cannot find the xctestrun file 'path/to/non_existent.xctestrun'")
        end
      )
    end
  end

  it 'returns all tests in a xctestrun for version 1' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('path/to/fake.xctestrun').and_return(true)
    allow(File).to receive(:read).with('path/to/fake.xctestrun').and_return(File.read('./spec/fixtures/fake.xctestrun'))
    allow(XCTestList)
      .to receive(:tests)
      .with('path/to/Debug-iphonesimulator/AtomicBoy.app/PlugIns/AtomicBoyTests.xctest', swift_test_prefix: 'test')
      .and_return(
        [
          'AtomicBoyTests/testUnit1',
          'AtomicBoyTests/testUnit2',
          'AtomicBoyTests/testUnit3'
        ]
      )

    allow(XCTestList)
      .to receive(:tests)
      .with('path/to/Debug-iphonesimulator/AtomicBoyUITests-Runner.app/PlugIns/AtomicBoyUITests.xctest', swift_test_prefix: 'test')
      .and_return(
        [
          'AtomicBoyTests/testUI1',
          'AtomicBoyTests/testUI2',
          'AtomicBoyTests/testUI3'
        ]
      )

    fastfile = "lane :test do
      tests_from_xctestrun(
        xctestrun: 'path/to/fake.xctestrun'
      )
    end"
    tests = Fastlane::FastFile.new.parse(fastfile).runner.execute(:test)
    expect(tests).to include(
      'Atomic Boy Tests' => [
        'Atomic Boy Tests/AtomicBoyTests/testUnit1',
        'Atomic Boy Tests/AtomicBoyTests/testUnit2',
        'Atomic Boy Tests/AtomicBoyTests/testUnit3'
      ],
      'AtomicBoyUITests' => [
        'AtomicBoyUITests/AtomicBoyTests/testUI1',
        'AtomicBoyUITests/AtomicBoyTests/testUI2',
        'AtomicBoyUITests/AtomicBoyTests/testUI3'
      ]
    )
  end

  it 'displays an error if no tests found in a xctestrun' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('path/to/fake.xctestrun').and_return(true)
    allow(File).to receive(:read).with('path/to/fake.xctestrun').and_return(File.read('./spec/fixtures/fake.xctestrun'))
    allow(XCTestList)
      .to receive(:tests)
      .with('path/to/Debug-iphonesimulator/AtomicBoy.app/PlugIns/AtomicBoyTests.xctest', swift_test_prefix: "test")
      .and_return([])
    allow(XCTestList)
      .to receive(:tests)
      .with('path/to/Debug-iphonesimulator/AtomicBoyUITests-Runner.app/PlugIns/AtomicBoyUITests.xctest', swift_test_prefix: "test")
      .and_return([])
    fastfile = "lane :test do
      tests_from_xctestrun(
        xctestrun: 'path/to/fake.xctestrun'
      )
    end"
    expect(FastlaneCore::UI).to receive(:error).with(/^No tests found.*/).twice
    expect(FastlaneCore::UI).to receive(:important).with(/^Is the Build Setting, `ENABLE_TESTABILITY` enabled.*/).twice
    tests = Fastlane::FastFile.new.parse(fastfile).runner.execute(:test)
    expect(tests).to eq({'Atomic Boy Tests' => [], 'AtomicBoyUITests' => [] })
  end

  it 'returns all the tests in useTestSelectionWhitelist enabled xctestrun file' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('path/to/fake2.xctestrun').and_return(true)
    allow(File).to receive(:read).with('path/to/fake2.xctestrun').and_return(File.read('./spec/fixtures/fake2.xctestrun'))
    expect(XCTestList).not_to receive(:tests)

    fastfile = "lane :test do
      tests_from_xctestrun(
        xctestrun: 'path/to/fake2.xctestrun'
      )
    end"
    tests = Fastlane::FastFile.new.parse(fastfile).runner.execute(:test)
    expect(tests).to include(
      'AtomicBoyTests' => [
        'AtomicBoyTests/AtomicBoyUITests/testExample',
        'AtomicBoyTests/AtomicBoyUITests/testExample2',
        'AtomicBoyTests/AtomicBoyUITests/testExample3',
        'AtomicBoyTests/AtomicBoyUITests/testExample4'
      ],
      'AtomicBoyUITests' => [
        'AtomicBoyUITests/AtomicBoyUITests/testExample',
        'AtomicBoyUITests/AtomicBoyUITests/testExample2',
        'AtomicBoyUITests/AtomicBoyUITests/testExample3',
        'AtomicBoyUITests/AtomicBoyUITests/testExample44'
      ]
    )
  end

  it 'returns all tests in a xctestrun for version 2' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('path/to/fake.xctestrun').and_return(true)
    allow(File).to receive(:read).with('path/to/fake.xctestrun').and_return(File.read('./spec/fixtures/format-version-2.xctestrun'))
    allow(XCTestList)
      .to receive(:tests)
      .with('path/to/DebugStage-iphonesimulator/TestAppUITests-Runner.app/PlugIns/TestAppUITests.xctest', swift_test_prefix: 'test')
      .and_return(
        [
          'AtomicBoyTests/testUnit1',
          'AtomicBoyTests/testUnit2',
          'AtomicBoyTests/testUnit3'
        ]
      )

    fastfile = "lane :test do
      tests_from_xctestrun(
        xctestrun: 'path/to/fake.xctestrun'
      )
    end"
    tests = Fastlane::FastFile.new.parse(fastfile).runner.execute(:test)
    expect(tests).to include(
      'TestAppUITests' => [
        'TestAppUITests/AtomicBoyTests/testUnit1',
        'TestAppUITests/AtomicBoyTests/testUnit2',
        'TestAppUITests/AtomicBoyTests/testUnit3'
      ]
    )
  end

  describe 'when the action is given an explicit swift_test_prefix' do
    it 'invokces XCTestList with the given swift_test_prefix' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('path/to/fake.xctestrun').and_return(true)
      allow(File).to receive(:read).with('path/to/fake.xctestrun').and_return(File.read('./spec/fixtures/format-version-2.xctestrun'))
      expect(XCTestList)
        .to receive(:tests)
        .with('path/to/DebugStage-iphonesimulator/TestAppUITests-Runner.app/PlugIns/TestAppUITests.xctest', swift_test_prefix: 'spec')
        .and_return([])

      fastfile = "lane :test do
        tests_from_xctestrun(
          xctestrun: 'path/to/fake.xctestrun',
          swift_test_prefix: 'spec'
        )
      end"

      tests = Fastlane::FastFile.new.parse(fastfile).runner.execute(:test)
    end
  end
end
