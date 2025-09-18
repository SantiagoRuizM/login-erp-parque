/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#FF6B35',
          50: '#FFF5F2',
          100: '#FFE8E0',
          200: '#FFD1C7',
          300: '#FFB8A3',
          400: '#FF9B7A',
          500: '#FF6B35',
          600: '#E55A2B',
          700: '#CC4A21',
          800: '#B33A17',
          900: '#992B0D',
        },
        secondary: {
          DEFAULT: '#E55A2B',
          light: '#FFF5F2',
          dark: '#CC4A21',
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      backgroundImage: {
        'login-gradient': 'linear-gradient(135deg, #FF6B35 0%, #E55A2B 100%)',
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
}