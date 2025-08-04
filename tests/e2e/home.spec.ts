import { test, expect } from '@playwright/test';

test('home page displays correctly', async ({ page }) => {
  await page.goto('/');
  
  // Test that the page loads
  await expect(page).toHaveTitle(/ShadowChat/);
  
  // Test that key elements are present
  await expect(page.locator('text=ShadowChat')).toBeVisible();
  
  // Test navigation elements
  await expect(page.locator('nav')).toBeVisible();
});

test('authentication page is accessible', async ({ page }) => {
  await page.goto('/authentication');
  
  // Test that authentication page loads
  await expect(page.locator('text=Connect')).toBeVisible();
});

test('chat page is accessible', async ({ page }) => {
  await page.goto('/chat');
  
  // Test that chat page loads (should be accessible even without auth)
  await expect(page).toHaveURL('/chat');
});

test('anonymous profile page is accessible', async ({ page }) => {
  await page.goto('/anonymous-profile');
  
  // Test that anonymous profile page loads
  await expect(page).toHaveURL('/anonymous-profile');
});