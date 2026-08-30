# frozen_string_literal: true

# Produces a human-readable device label ("Chrome on macOS") from a raw
# User-Agent header for the device sessions list.
class DeviceNameParser
    BROWSERS = {
        /edg/i => "Edge",
        /opr|opera/i => "Opera",
        /chrome/i => "Chrome",
        /safari/i => "Safari",
        /firefox/i => "Firefox"
    }.freeze

    PLATFORMS = {
        /iphone|ipad/i => "iOS",
        /android/i => "Android",
        /macintosh|mac os/i => "macOS",
        /windows/i => "Windows",
        /linux/i => "Linux"
    }.freeze

    def self.parse(user_agent)
        return "Unknown device" if user_agent.blank?

        browser = BROWSERS.find { |pattern, _| user_agent.match?(pattern) }&.last || "Browser"
        platform = PLATFORMS.find { |pattern, _| user_agent.match?(pattern) }&.last

        platform ? "#{browser} on #{platform}" : browser
    end
end
