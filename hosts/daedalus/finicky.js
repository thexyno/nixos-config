module.exports = {
  defaultBrowser: "Arc.app",
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
      match: 'localhost:44422',
      browser: "Vivaldi.app"
    },
    {
      match: 'localhost:7104',
      browser: "Vivaldi.app"
    }

  ]
}
