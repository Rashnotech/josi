import { useEffect, useState } from "react";
import { Navigate, Route, Routes, useLocation } from "react-router-dom";
import Header from "./components/Header.jsx";
import Footer from "./components/Footer.jsx";
import PageLoader from "./components/PageLoader.jsx";
import CourierPage from "./pages/CourierPage.jsx";
import ForgotPasswordPage from "./pages/ForgotPasswordPage.jsx";
import Home from "./pages/Home.jsx";
import LoginPage from "./pages/LoginPage.jsx";
import MobileAppContinuePage from "./pages/MobileAppContinuePage.jsx";
import PackOwnerPage from "./pages/PackOwnerPage.jsx";
import RegistrationPage from "./pages/RegistrationPage.jsx";
import RiderPage from "./pages/RiderPage.jsx";
import { registrationPages } from "./data/registrationPages.js";

export default function App() {
  const location = useLocation();
  const [isLoading, setIsLoading] = useState(true);
  const isAuthRoute = [
    "/login",
    "/sign-in",
    "/forgot-password",
    "/forgotPassword",
    "/forget-password",
    "/continue-in-mobile-app",
  ].includes(location.pathname);

  useEffect(() => {
    window.scrollTo({ top: 0, left: 0, behavior: "auto" });
  }, [location.pathname]);

  useEffect(() => {
    setIsLoading(true);
    const timer = window.setTimeout(() => {
      setIsLoading(false);
    }, location.key === "default" ? 900 : 420);

    return () => window.clearTimeout(timer);
  }, [location.pathname, location.key]);

  return (
    <div className="min-h-screen bg-white text-ink">
      <PageLoader isVisible={isLoading} />
      {!isAuthRoute && <Header />}
      <div key={location.pathname} className="page-transition">
        <Routes location={location}>
          <Route path="/" element={<Home />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/sign-in" element={<Navigate to="/login" replace />} />
          <Route path="/forgot-password" element={<ForgotPasswordPage />} />
          <Route
            path="/continue-in-mobile-app"
            element={<MobileAppContinuePage />}
          />
          <Route
            path="/forgotPassword"
            element={<Navigate to="/forgot-password" replace />}
          />
          <Route
            path="/forget-password"
            element={<Navigate to="/forgot-password" replace />}
          />
          <Route path="/become-a-rider" element={<RiderPage />} />
          <Route path="/become-a-courier" element={<CourierPage />} />
          <Route
            path="/sign-up-as-a-pack-owner"
            element={<PackOwnerPage />}
          />
          {registrationPages.map((page) => (
            <Route
              key={page.path}
              path={page.path}
              element={<RegistrationPage page={page} />}
            />
          ))}
          <Route
            path="/become-a-driver"
            element={<Navigate to="/become-a-rider" replace />}
          />
          <Route
            path="/fleet-owner"
            element={<Navigate to="/sign-up-as-a-pack-owner" replace />}
          />
          <Route
            path="/pack-owner"
            element={<Navigate to="/sign-up-as-a-pack-owner" replace />}
          />
          <Route
            path="/sign-up-as-a-fleet-owner"
            element={<Navigate to="/sign-up-as-a-pack-owner" replace />}
          />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </div>
      {!isAuthRoute && <Footer />}
    </div>
  );
}
