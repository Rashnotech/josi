/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,jsx}"],
  theme: {
    extend: {
      colors: {
        ink: "#0a0a0a",
        muted: "#5f6368",
        paper: "#f6f6f6",
        line: "#e6e6e6",
        josi: {
          red: "#ec111a",
          darkRed: "#9f0f14",
          black: "#050505",
        },
      },
      fontFamily: {
        sans: ['"Urbanist"', "Inter", "system-ui", "sans-serif"],
        display: ['"Pogonia"', '"Urbanist"', "system-ui", "sans-serif"],
      },
      boxShadow: {
        menu: "0 22px 70px rgba(0, 0, 0, 0.22)",
        soft: "0 18px 50px rgba(0, 0, 0, 0.08)",
      },
    },
  },
  plugins: [],
};
