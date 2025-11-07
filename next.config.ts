import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  reactStrictMode: true,
  // Disable static optimization for error pages to avoid context issues
  experimental: {
    optimizePackageImports: ['next'],
  },
};

export default nextConfig;
