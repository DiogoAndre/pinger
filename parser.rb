# encoding: UTF-8

def parse_pinger(file_name)
  section = []
  timestamps = Hash.new
  locations = Hash.new
  this_loc = 0
  File.foreach(file_name) do |line|
    case line
    when /^Start(\w+)/
      section.push $1
      #puts "Section #{$1} started"
      next
    when /^End(\w+)/
      section.pop
      # puts "Section #{$1} ended"
      next
    end

    case section
    when ["TimeStamp"]
      stamptype , stampvalue = line.split ' ', 2
      timestamps[stamptype] = stampvalue
    when ["Location", "LocationIdentity"]
      case line
      when /id (?<id>\d{1,2}) name (?<name>\w.*)/
        this_loc = $1
        locations[this_loc] = { "id" => $1, "name" => $2}
      end
    when ["Location","PingInfo"]
      case line
      when /Target IP address: (?<ip>\w.*)/
        locations[this_loc].merge!({"ip_address" => $1})
      when /Success rate is (?<packet_loss>\d{1,3})*.*round-trip min\/avg\/max = (?<min>\w.{1,3})\/(?<avg>\w.{1,3})\/(?<max>\w.{1,3})/
        locations[this_loc].merge!({"sucess_rate" => $1})
        locations[this_loc].merge!({"trip_min" => $2})
        locations[this_loc].merge!({"trip_avg" => $3})
        locations[this_loc].merge!({"trip_max" => $4})
      end
    else 
      next
    end
  end
  locations
end

content = "id,name,ip_address,sucess_rate,trip_min,trip_avg,trip_max\n"
parse_pinger(ARGF.argv[0]).each do |hid,currline|

  content << "#{currline["id"]},#{currline["name"]},#{currline["ip_address"]},#{currline["sucess_rate"]},#{currline["trip_min"]},#{currline["trip_avg"]},#{currline["trip_max"]}\n"

end

newfile = File.new("csv-#{ARGF.argv[0]}.csv", "w:UTF-8")
newfile.write(content.delete("\r"))
newfile.close
