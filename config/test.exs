import Config

config :wallaby,
  base_url: "http://localhost:4000",
  chromedriver: [
    headless: true
  ],
  screenshot_on_failure: true
