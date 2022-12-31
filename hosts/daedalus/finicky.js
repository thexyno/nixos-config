module.exports = {
  defaultBrowser: "Orion",
  handlers: [
    {
      match: /^https?:\/\/gitlab\.com\/.*$/,
      browser: "Vivaldi.app"
    },
    {
      match: /^https?:\/\/.*\.atlassian\.com\/.*$/,
      browser: "Vivaldi.app"
    }
  ]
}
