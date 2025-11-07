/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Disable static optimization for error pages to avoid context issues
  experimental: {
    optimizePackageImports: ['next'],
  },
};

module.exports = nextConfig;

