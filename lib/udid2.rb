require 'digest/sha1'
class Udid2

  attr_accessor :udid2, :clear, :hash, :mode, :number

  @@type = 'udid2'

  # Create an udid2
  #
  #   language: (String)
  def to_udid2(last_name, first_name, birthdate,latitude,longitude)

    latitude = Float(latitude)
    longitude = Float(longitude)

    #get only ascci
    last_name = last_name[0..25].gsub(/[^a-z ]/i, '').upcase
    first_name = first_name[0..26].gsub(/[^a-z-]/i, '').upcase

    #verify latitude and longitude
    return 0 if (latitude > 90 || latitude < -90)
    return 0 if (longitude > 180 || longitude <= -180)

    #add 0
    i_latitude =  latitude.to_s.split('.')[0]
    i_longitude =  longitude.to_s.split('.')[0]

    f_latitude =  latitude.to_s.split('.')[1]
    f_longitude =  longitude.to_s.split('.')[1]

    i_latitude = "%02d" % i_latitude
    i_longitude = "%03d" % i_longitude

    f_latitude = "#{f_latitude}00"[0..1]
    f_longitude = "#{f_longitude}00"[0..1]

    #add + or -
    latitude > 0 ? i_latitude = "+#{i_latitude}" : i_latitude = "-#{i_latitude}"
    longitude > 0 ? i_longitude = "+#{i_longitude}" : i_longitude = "-#{i_longitude}"

    @be_hash =  "#{last_name};#{first_name};#{birthdate.to_s};e#{i_latitude}.#{f_latitude};#{i_longitude}.#{f_longitude}"
    @clear = "#{@@type};c;#{@be_hash};0;"

    @hash = Digest::SHA1.hexdigest @be_hash

    @udid2 = "#{@@type};h;#{@hash};0;"

  end

  # Create object Udid2 from existing udid2 string
  #
  #   language: (String)
  def udid2(udid2)
    tab_hash = udid2.split(';')
    @type = tab_hash[0]

    return 'error_type' if @type != @@type

    @mode = tab_hash[1]

    if @mode == 'h' && tab_hash.length == 4
      @hash = tab_hash[2]
      @number = tab_hash[3]
    elsif @mode == 'c' && tab_hash.length == 8
      to_udid2 tab_hash[2],tab_hash[3], tab_hash[4], tab_hash[5][1..6], tab_hash[6]
    else
      return 'error mode'
    end

  end

  #Verify an udid2
  def self.is_udid2? udid2
    tab_hash = udid2.split(';')

    type = tab_hash[0]

    return false if type != @@type

    mode = tab_hash[1]

    if mode == 'h' && tab_hash.length == 4
      return true
    elsif mode == 'c' && tab_hash.length == 8
      s = self.new
      s.to_udid2 tab_hash[2],tab_hash[3], tab_hash[4], tab_hash[5][1..6], tab_hash[6]

      return false if udid2 != s.clear

      return true
    else
      return false
    end



  end


end