/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        playfair: ['"Playfair Display"', "serif"],
        inter: ['"Inter"', "sans-serif"]
      },
      keyframes: {
        glowPulse: {
          "0%, 100%": { boxShadow: "0 0 25px rgba(255,188,255,0.35)" },
          "50%": { boxShadow: "0 0 45px rgba(255,188,255,0.6)" }
        },
        fadeSlideUp: {
          "0%": { opacity: "0", transform: "translateY(12px)" },
          "100%": { opacity: "1", transform: "translateY(0)" }
        }
      },
      animation: {
        glowPulse: "glowPulse 3s ease-in-out infinite",
        fadeSlideUp: "fadeSlideUp 0.6s ease-out both"
      }
    }
  },
  plugins: []
};

