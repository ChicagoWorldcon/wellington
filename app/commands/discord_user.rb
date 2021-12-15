class DiscordUser
  
  attr_reader :membership_number, :email

  def initialize(membership_number: , email: )
    @memno = membership_number
    @email = email
  end
  
  def token
    emailp = (email[1]== '@' ? '-' : '') + email      # Make email two characters
    base = SecureRandom.base64(9).gsub(/[+\/=]/, '')  # Build random base string
    idx = rand(3)                                     # Pick a number
    flet = ['S','C','h'][idx]
    secchr = emailp[1]

    case secchr + idx.to_s
    when /[ABCDEabcde]0/ then rgx="u" 
    when /[ABCDEabcde]1/ then rgx="W" 
    when /[ABCDEabcde]2/ then rgx="y" 
    when /[FGHIJfghij]0/ then rgx="z"
    when /[FGHIJfghij]1/ then rgx="4" 
    when /[FGHIJfghij]2/ then rgx="7" 
    when /[.KLMNOklmno]0/ then rgx="P"
    when /[.KLMNOklmno]1/ then rgx="s"
    when /[.KLMNOklmno]2/ then rgx="q"
    when /[-PQRSTpqrst]0/ then rgx="J"
    when /[-PQRSTpqrst]1/ then rgx="i"
    when /[-PQRSTpqrst]2/ then rgx="F"
    when /[_UVWXYuvwxy]0/ then rgx="c"
    when /[_UVWXYuvwxy]1/ then rgx="E"
    when /[_UVWXYuvwxy]2/ then rgx="D"
    when /[Zz0123456789]0/ then rgx="m"
    when /[Zz0123456789]1/ then rgx="O"
    when /[Zz0123456789]2/ then rgx="K"
    end

    memp = "%05d" % @memno                      # pad to 5 digits
    checkd = (memp[3].to_i + memp[4].to_i) % 8  # calc checksom on bottom 2 digits

    base[2] = flet
    base[4] = checkd.to_s
    base[5] = rgx

    auth = "auth " + base[0..7] + " " + memp + " " + emailp
    return auth
  end
end