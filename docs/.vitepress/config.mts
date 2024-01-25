import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Fray Documentation",
  description: "Modular combat framework for Godot 4",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: "/public/assets/icons/fray-logo-2.png",
    search: {
      provider: "local",
    },
    nav: [{ text: "Docs", link: "/introduction/what-is-fray" }],
    editLink: {
      pattern: "https://github.com/Pyxus/fray/tree/main/docs/:path",
      text: "Edit this page on GitHub",
    },
    lastUpdated: {
      text: "Updated at",
      formatOptions: {
        dateStyle: "full",
        timeStyle: "medium",
      },
    },
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
            text: "Building A State Machine",
            link: "/state-management/building-a-state-machine",
          },
          {
            text: "Providing Data To States",
            link: "/state-management/providing-data-to-states",
          },
          {
            text: "Controlling State Transitions",
            link: "/state-management/controlling-state-transitions",
          },
          {
            text: "Using Input Transitions",
            link: "/state-management/using-input-transitions",
          },
          {
            text: "Using Global Transitions",
            link: "/state-management/using-global-transitions",
          },
        ],
      },
      {
        text: "Input Module",
        collapsed: false,
        link: "/input/overview",
        items: [
          {
            text: "Registering Inputs",
            link: "/input/registering-inputs",
          },
          {
            text: "Detecting Inputs",
            link: "/input/detecting-inputs",
          },
          {
            text: "Detecting Input Sequences",
            link: "/input/detecting-input-sequences",
          },
        ],
      },
      {
        text: "Hit Module",
        collapsed: false,
        link: "/hit/overview",
        items: [
          {
            text: "Creating Hitboxes",
            link: "/hit/creating-hitboxes",
          },
          {
            text: "Managing Hitboxes",
            link: "/hit/managing-hitboxes",
          },
        ],
      },
    ],

    socialLinks: [
      { icon: "github", link: "https://github.com/Pyxus/fray" },
      { icon: "twitter", link: "https://twitter.com/pyxus" },
    ],
  },
});
