# Josi Web

Josi Web is the React frontend for Josi Transport and Logistics Nigeria. It is a Vite single-page application built with React, React Router, Tailwind CSS, Urbanist typography, Pogonia display typography, and lucide-react icons.

The current build includes the public landing page, registration pages for riders/couriers/pack owners, login, forgot password, loading animation, route transitions, and mobile-first responsive layouts.

## Tech Stack

- React 19
- Vite 6
- React Router 7
- Tailwind CSS 3
- lucide-react icons
- Urbanist for body typography
- Pogonia for display/header typography

## Getting Started

Install dependencies:

```bash
npm install
```

Start the local development server:

```bash
npm run dev
```

Build for production:

```bash
npm run build
```

Preview the production build:

```bash
npm run preview
```

On Windows PowerShell, use `npm.cmd` if script execution policy blocks `npm`:

```bash
npm.cmd run build
```

## API Configuration

Create a local `.env` file for the Laravel API base URL:

```bash
VITE_API_BASE_URL=http://localhost:8000/api/v1
```

Auth forms use `src/services/authApi.js`; do not call `fetch` directly from pages.

## Routes

| Route | Page |
| --- | --- |
| `/` | Home page |
| `/login` | Login page |
| `/sign-in` | Redirects to `/login` |
| `/forgot-password` | Forgot password page |
| `/forgotPassword` | Redirects to `/forgot-password` |
| `/forget-password` | Redirects to `/forgot-password` |
| `/become-a-rider` | Rider registration/marketing page |
| `/become-a-courier` | Courier registration/marketing page |
| `/sign-up-as-a-pack-owner` | Pack owner registration/marketing page |
| `/become-a-driver` | Redirects to `/become-a-rider` |
| `/fleet-owner` | Redirects to `/sign-up-as-a-pack-owner` |
| `/pack-owner` | Redirects to `/sign-up-as-a-pack-owner` |
| `/sign-up-as-a-fleet-owner` | Redirects to `/sign-up-as-a-pack-owner` |

## Main Features

- Sticky black header with Josi logo, register dropdown, and hamburger navigation.
- Register dropdown links to rider, courier, and pack owner pages.
- Home hero uses the Josi brand image and red/black overlay styling.
- Home page service cards link to rider and courier pages.
- Account section login button links to `/login`.
- Rider, courier, and pack owner pages use mobile-first responsive sections.
- Courier earnings and delivery steps use button-controlled mobile carousels.
- Login page calls `/api/v1/auth/login`, stores the returned token in the shared auth provider, and redirects by role.
- Rider and courier registration call `/api/v1/auth/register` and show the email-check success state without dashboard navigation.
- Pack owner registration calls `/api/v1/auth/register`, keeps the vehicle-count field, and redirects to `/login` after account creation.
- Pack owner login calls `/api/v1/auth/login`, stores the returned token, writes a dashboard cookie, and redirects to the Laravel dashboard URL returned by the backend.
- Forgot password calls `/api/v1/auth/forgot-password`, `/api/v1/auth/verify-reset-code`, and `/api/v1/auth/reset-password`.
- The dashboard UI is not in this React app. It is served by Laravel from the backend.
- Page loader and route transition animations are included.
- Route navigation resets scroll position to the top of the new page.

## Project Structure

```text
src/
  assets/              Static images and brand assets
  components/          Shared UI components and page sections
  data/                Shared route/dropdown data
  pages/               Route-level pages
  App.jsx              Router, layout chrome, loader, redirects
  main.jsx             React entry point
  index.css            Tailwind layers, fonts, global animation styles
```

## Important Files

- `src/App.jsx` defines routes, redirects, auth-page layout behavior, loader timing, and scroll reset.
- `src/components/Header.jsx` renders the Josi header, register dropdown trigger, and mobile menu.
- `src/auth/AuthContext.jsx` restores the session through `/auth/me`, stores auth state, and handles logout.
- `src/services/authApi.js` is the single Laravel API client for web auth.
- `src/components/AuthRegistrationForm.jsx` powers rider, courier, and pack owner registration.
- `src/components/RegisterDropdown.jsx` renders the registration option menu.
- `src/data/registerOptions.jsx` stores the register dropdown options.
- `src/pages/Home.jsx` composes the landing page sections.
- `src/pages/RiderPage.jsx` builds the rider onboarding page.
- `src/pages/CourierPage.jsx` builds the courier onboarding page.
- `src/pages/PackOwnerPage.jsx` builds the pack owner onboarding page.
- `src/pages/LoginPage.jsx` builds the login page.
- `src/pages/ForgotPasswordPage.jsx` builds the forgot password page.
- `src/components/PageLoader.jsx` renders the loading overlay.

## Styling Notes

Brand colors are defined in `tailwind.config.js`:

- `josi.red`: `#ec111a`
- `josi.darkRed`: `#9f0f14`
- `josi.black`: `#050505`
- `ink`: `#0a0a0a`
- `muted`: `#5f6368`
- `paper`: `#f6f6f6`
- `line`: `#e6e6e6`

Fonts are configured in Tailwind:

- `font-sans`: Urbanist
- `font-display`: Pogonia

Global animations and hover behavior live in `src/index.css`.

## Assets Used

Current image assets live in `src/assets/` and include:

- `josi-logo.jpeg`, `josi-logo.png`
- `home.png`
- `passenger.jpg`
- `waybill.png`
- `scooter.png`
- `courier.png`
- `bikes.png`
- `deliver.jpg`
- `apply.png`
- `document.png`
- `ride.png`
- `ride_earn.png`
- `schedule.png`
- `wallet.png`
- `money.png`
- `parcel.jpeg`
- `calendar.jpeg`
- `michael.jpg`
- `holder-package.jpg`

## Build Check

The latest implementation has been verified with:

```bash
npm.cmd run build
```

## Notes for Future Work

- Connect login, forgot password, and registration forms to backend APIs when endpoints are ready.
- Add form validation and submission states.
- Optimize large image assets before production deployment.
- Replace any remaining placeholder or static copy with final product/legal content.
