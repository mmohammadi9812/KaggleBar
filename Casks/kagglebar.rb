cask "kagglebar" do
  version "1.0.0"
  sha256 :no_check

  url "https://github.com/mmohammadi9812/KaggleBar/releases/download/v#{version}/KaggleBar.dmg"
  name "KaggleBar"
  desc "Menu bar app for Kaggle accelerator quota, account switching, and session monitoring"
  homepage "https://github.com/mmohammadi9812/KaggleBar"

  depends_on macos: ">= :sonoma"

  app "KaggleBar.app"

  zap trash: [
    "~/.kaggle/accounts.json",
    "~/.config/kagglebar/config.json",
    "~/Library/LaunchAgents/com.local.kagglebar.plist",
    "~/Library/Preferences/com.local.kagglebar.plist",
  ]
end
