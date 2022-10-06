module.exports = {
  defaultBrowser: "Safari",
  handlers: [
    {
      match: /^https?:\/\/gitlab\.com\/.*$/,
      browser: "Vivaldi.app"
    },
    {
      match: /^https?:\/\/.*\.atlassian\.com\/.*$/,
      browser: "Vivaldi.app"
    },
    {
      match: undefined,
      browser: "Safari"
    }
  ]
}
