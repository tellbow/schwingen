/// <reference types="vitest/config" />
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
	test: {
		environment: 'jsdom',
		include: ['src/**/*.test.ts']
	},
	plugins: [
		tailwindcss(),
		sveltekit(),
		VitePWA({
			registerType: 'autoUpdate',
			includeAssets: ['favicon.ico', 'images/logos/*.png', 'images/logos/*.webp'],
			manifest: {
				name: 'Tellbow - Schwingen',
				short_name: 'Tellbow',
				description: 'Alles rund ums Schwingen',
				theme_color: '#78350f',
				background_color: '#ffffff',
				display: 'standalone',
				start_url: '/',
				lang: 'de',
				categories: ['sports', 'entertainment'],
				icons: [
					{
						src: 'images/logos/tellbow_192x192.png',
						sizes: '192x192',
						type: 'image/png',
						purpose: 'any'
					},
					{
						src: 'images/logos/tellbow_192x192.webp',
						sizes: '192x192',
						type: 'image/webp',
						purpose: 'any'
					},
					{
						src: 'images/logos/tellbow_512x512.png',
						sizes: '512x512',
						type: 'image/png',
						purpose: 'any'
					},
					{
						src: 'images/logos/tellbow_circle.png',
						sizes: '512x512',
						type: 'image/png',
						purpose: 'maskable'
					}
				]
			},
			workbox: {
				globPatterns: ['**/*.{js,css,html,ico,png,svg,webp,woff2}'],
				runtimeCaching: [
					{
						urlPattern: /^.*\/api\/collections\/.*/,
						handler: 'NetworkFirst',
						options: {
							cacheName: 'api-cache',
							expiration: {
								maxAgeSeconds: 300
							}
						}
					},
					{
						urlPattern: /\.(?:png|jpg|jpeg|svg|gif|webp)$/,
						handler: 'CacheFirst',
						options: {
							cacheName: 'image-cache',
							expiration: {
								maxEntries: 100,
								maxAgeSeconds: 60 * 60 * 24 * 30
							}
						}
					}
				]
			}
		})
	]
});
