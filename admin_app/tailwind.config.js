export default {
  content: [
  './index.html',
  './src/**/*.{js,ts,jsx,tsx}'
],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        mono: ['JetBrains Mono', 'ui-monospace', 'monospace'],
      },
      colors: {
        canvas: '#FAFAFA',
        surface: '#FFFFFF',
        ink: {
          DEFAULT: '#1A1A1A',
          soft: '#454545',
          muted: '#6E6E6E',
          faint: '#98989A',
        },
        line: {
          DEFAULT: '#E7E7E8',
          strong: '#D5D5D7',
          soft: '#F1F1F2',
        },
        coral: {
          DEFAULT: '#FF3B4E',
          hover: '#E92C3F',
          ink: '#A81C2A',
          soft: '#FFF1F2',
          border: '#FFCFD4',
        },
        ok: {
          DEFAULT: '#0F7B55',
          ink: '#0B5C40',
          soft: '#EAF7F1',
          border: '#BEE5D5',
        },
        warn: {
          DEFAULT: '#B45309',
          ink: '#8A3F06',
          soft: '#FEF6E7',
          border: '#F3DBB2',
        },
        info: {
          DEFAULT: '#2A5BD7',
          soft: '#EEF2FE',
          border: '#CBD8F8',
        },
      },
      fontSize: {
        '2xs': ['11px', '14px'],
        xs: ['12px', '16px'],
        sm: ['13px', '18px'],
        base: ['14px', '20px'],
        md: ['15px', '22px'],
        lg: ['16px', '24px'],
        xl: ['18px', '26px'],
        '2xl': ['22px', '30px'],
        '3xl': ['26px', '34px'],
        '4xl': ['32px', '40px'],
      },
      borderRadius: {
        DEFAULT: '8px',
        md: '8px',
        lg: '10px',
        xl: '12px',
      },
      boxShadow: {
        card: '0 1px 2px rgba(20,20,22,0.05)',
        pop: '0 12px 32px rgba(20,20,22,0.12)',
      },
      transitionTimingFunction: {
        exp: 'cubic-bezier(0.23, 1, 0.32, 1)',
      },
    },
  },
  plugins: [],
}
