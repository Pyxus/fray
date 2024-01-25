import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Fray",
  description: "Modular combat framework for Godot 4",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: "/assets/icons/fray-logo-2.png",
    search: {
      provider: "local",
    },
    nav: [{ text: "Docs", link: "/introduction/what-is-fray" }],

    sidebar: [
      {
        text: "Introduction",
        collapsed: false,
        items: [
          { text: "What is fray?", link: "/introduction/what-is-fray" },
          { text: "Installation", link: "/introduction/installation" },
        ],
      },
      {
        text: "State Management Module",
        collapsed: false,
        link: "/state-management/overview",
        items: [
          {
            text: "Guide",
            collapsed: false,
            items: [
              {
                text: "Building A State Machine",
                link: "/state-management/guide/building-a-state-machine",
              },
              {
                text: "Providing Data To States",
                link: "/state-management/guide/providing-data-to-states",
              },
              {
                text: "Controlling State Transitions",
                link: "/state-management/guide/controlling-state-transitions",
              },
              {
                text: "Using Input Transitions",
                link: "/state-management/guide/using-input-transitions",
              },
              {
                text: "Using Global Transitions",
                link: "/state-management/guide/using-global-transitions",
              },
            ],
          },
        ],
      },
      {
        text: "Input Module",
        collapsed: false,
        link: "/input/overview",
        items: [
          {
            text: "Guide",
            collapsed: false,
            items: [
              {
                text: "Registering Inputs",
                link: "/input/guide/registering-inputs",
              },
              {
                text: "Detecting Inputs",
                link: "/input/guide/detecting-inputs",
              },
              {
                text: "Detecting Input Sequences",
                link: "/input/guide/detecting-input-sequences",
              },
            ],
          },
        ],
      },
      {
        text: "Hit Module",
        collapsed: false,
        link: "/hit/overview",
        items: [],
      },
    ],

    socialLinks: [
      { icon: "github", link: "https://github.com/Pyxus/fray" },
      { icon: "twitter", link: "https://twitter.com/pyxus" },
    ],
  },
});
