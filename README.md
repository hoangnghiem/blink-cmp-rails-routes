# blink-cmp-rails-routse

Adds Ruby on Rails route suggestions as a source for [Saghen/blink.cmp](https://github.com/Saghen/blink.cmp)

## Installation

### lazy.nvim

```lua
return {
  {
    "saghen/blink.cmp",
    dependencies = { "hoangnghiem/blink-cmp-rails-routes" },
    opts = {
      sources = {
        providers = {
          rails_routes = {
            module = "blink-cmp-rails-routes",
            name = "Rails routes",
          },
        },
      },
    },
  },
}
```
