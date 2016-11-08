class FakeSFTPConnection
  def self.dir
    self
  end

  def self.glob(*args)
    [
      FakeFile.new('ACHP08111605'),
      FakeFile.new('ACHP08111601'),
      FakeFile.new('ACHP08111602')
    ]
  end

  def self.file
    self
  end

  def self.open(*args, &block)
    if block_given?
      yield FakeFile.new('TestFile')
    elsif args[0].try(:end_with?, 'most_recent')
      FakeFile.new('most_recent', DateTime.yesterday.to_time.to_s)
    elsif args[0].try(:include?, 'status_check')
      FakeFile.new('status_check',
"""111 111111111 1111111111111111111A111111AAAAAAAAAAAAA          AAAAAAA AAAAAA      AAAAAA
5111AAAAAAAAAAAAAAAA                    1111111111CCDPAYMENTS  1111111111111111111111110000001
611111111111111111111111     0000000100T005           AAAAAAA AAAAAAAAA       0111111111111111
820000000100011000130000000001000000000000001111111111                         111111110000001
9000001000001000000010001100013000000000100000000000000
9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
""")
    else
      self
    end
  end

  def self.entries(*args)
    [
      OpenStruct.new({
        name: 'status_check_1',
        attributes: OpenStruct.new({
          mtime: Time.now.to_i
        })
      }),
      OpenStruct.new({
        name: 'status_check_2',
        attributes: OpenStruct.new({
          mtime: (DateTime.yesterday.to_time - 1.hour).to_i
        })
      })
    ]
  end

  def self.read
    'test file contents blah blah blah'
  end

  class FakeFile

    attr_reader :name, :contents

    def initialize(name, contents = "")
      @name = name
      @contents = contents
    end

    def puts(*)
    end

    def read
      @contents
    end

    def write(*args)
    end
  end
end
