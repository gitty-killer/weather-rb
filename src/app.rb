FIELDS = ["day", "condition", "high", "low"]
NUMERIC_FIELD = "high"
STORE_PATH = File.join('data', 'store.txt')


def parse_kv(items)
  record = {}
  items.each do |item|
    key, value = item.split('=', 2)
    raise "Invalid item: #{item}" unless value
    raise "Unknown field: #{key}" unless FIELDS.include?(key)
    raise "Value may not contain '|'" if value.include?('|')
    record[key] = value
  end
  FIELDS.each { |f| record[f] ||= '' }
  record
end


def format_record(values)
  FIELDS.map { |k| "#{k}=#{values[k] || ''}" }.join('|')
end


def parse_line(line)
  values = {}
  line.strip.split('|').each do |part|
    next if part.empty?
    key, value = part.split('=', 2)
    raise "Bad part: #{part}" unless value
    values[key] = value
  end
  values
end


def load_records
  return [] unless File.exist?(STORE_PATH)
  File.read(STORE_PATH).lines.map(&:strip).reject(&:empty?).map { |l| parse_line(l) }
end


def append_record(values)
  Dir.mkdir('data') unless Dir.exist?('data')
  File.open(STORE_PATH, 'a') { |f| f.puts(format_record(values)) }
end


def summary(records)
  count = records.length
  return "count=#{count}" if NUMERIC_FIELD.nil?
  total = records.map { |r| r[NUMERIC_FIELD].to_i }.sum
  "count=#{count}, #{NUMERIC_FIELD}_total=#{total}"
end


def main(argv)
  cmd = argv.shift
  unless cmd
    puts 'Usage: init | add key=value... | list | summary'
    return 2
  end
  case cmd
  when 'init'
    Dir.mkdir('data') unless Dir.exist?('data')
    File.write(STORE_PATH, '')
    0
  when 'add'
    append_record(parse_kv(argv))
    0
  when 'list'
    load_records.each { |r| puts(format_record(r)) }
    0
  when 'summary'
    puts(summary(load_records))
    0
  else
    warn "Unknown command: #{cmd}"
    2
  end
end

exit(main(ARGV)) if __FILE__ == $0
