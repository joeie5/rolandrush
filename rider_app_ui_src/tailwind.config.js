export default {
  content: [
  './index.html',
  './src/**/*.{js,ts,jsx,tsx}'
],
  theme: {
    extend: {
      colors: {
        canvas: '#FAFAFA',
        surface: '#FFFFFF',
        ink: {
          DEFAULT: '#1A1A1A',
          muted: '#6B6B6B',
          faint: '#9A9A9A',
        },
        line: '#EAEAEA',
        coral: {
          DEFAULT: '#FF3B4E',
          hover: '#E62E40',
          soft: '#FFECEE',
        },
        online: {
          DEFAULT: '#12B76A',
          hover: '#0E9A59',
          soft: '#E4F8EE',
        },
        alert: {
          DEFAULT: '#F79009',
          hover: '#DD7B03',
          soft: '#FFF3E2',
        },
      },
      fontFamily: {
        sans: ['"Plus Jakarta Sans"', 'system-ui', 'sans-serif'],
      },
      fontSize: {
        micro: ['0.8125rem', { lineHeight: '1.1rem', letterSpacing: '0.01em' }],
        stat: ['2.75rem', { lineHeight: '1', letterSpacing: '-0.03em' }],
        hero: ['3.75rem', { lineHeight: '1', letterSpacing: '-0.04em' }],
      },
      borderRadius: {
        card: '16px',
        btn: '12px',
      },
      boxShadow: {
        float: '0 8px 24px -6px rgba(26,26,26,0.18)',
        sheet: '0 -10px 30px -12px rgba(26,26,26,0.22)',
      },
      transitionTimingFunction: {
        swift: 'cubic-bezier(0.23, 1, 0.32, 1)',
      },
    },
  },
  plugins: [],
}
