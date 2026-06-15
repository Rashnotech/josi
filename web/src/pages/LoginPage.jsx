import { useState } from "react";
import { Eye, EyeOff, Loader2, LockKeyhole } from "lucide-react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import logoUrl from "../assets/josi-logo.png";
import { useAuth } from "../auth/AuthContext.jsx";
import {
  dashboardUrlFromResponse,
  firstValidationMessage,
  redirectForRole,
} from "../services/authApi.js";

export default function LoginPage() {
  const [isPasswordVisible, setIsPasswordVisible] = useState(false);
  const [emailOrPhone, setEmailOrPhone] = useState("");
  const [password, setPassword] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const successMessage = location.state?.message;

  async function handleSubmit(event) {
    event.preventDefault();
    setErrorMessage("");
    setIsSubmitting(true);

    try {
      const data = await login({ emailOrPhone, password });
      if (["pack_owner", "fleet_owner", "admin", "super_admin"].includes(data.user?.role)) {
        window.location.assign(dashboardUrlFromResponse(data));
        return;
      }

      navigate(data.redirect_to || redirectForRole(data.user?.role, "/continue-in-mobile-app"), {
        replace: true,
      });
    } catch (error) {
      setErrorMessage(firstValidationMessage(error));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <main className="min-h-screen bg-white px-5 py-7 text-ink sm:px-8 lg:py-9">
      <div className="mx-auto flex w-full max-w-md flex-col items-center">
        <Link
          to="/"
          className="focus-ring inline-flex rounded-lg"
          aria-label="Go to Josi home"
        >
          <img
            src={logoUrl}
            alt="Josi logo"
            className="h-20 w-20 rounded-md object-contain"
          />
        </Link>

        <section className="mt-10 w-full sm:mt-12">
          <h1 className="text-center font-display text-2xl font-bold leading-tight sm:text-3xl">
            Sign in to your account
          </h1>

          <form className="auth-form mt-8 grid gap-5" onSubmit={handleSubmit}>
            {successMessage && (
              <div className="rounded-lg border border-green-200 bg-green-50 p-3 text-sm font-semibold leading-relaxed text-green-800">
                {successMessage}
              </div>
            )}

            <label className="grid gap-2.5">
              <span className="text-sm font-extrabold sm:text-base">
                Email or phone <span className="text-josi-red">*</span>
              </span>
              <input
                type="text"
                autoComplete="username"
                value={emailOrPhone}
                onChange={(event) => setEmailOrPhone(event.target.value)}
                className="focus-ring h-14 rounded-lg border-0 bg-[#edf0ef] px-5 text-base font-semibold text-ink outline-none"
                aria-label="Email or phone"
                required
              />
            </label>

            <label className="grid gap-2.5">
              <span className="text-sm font-extrabold sm:text-base">
                Password <span className="text-josi-red">*</span>
              </span>
              <div className="focus-within:outline focus-within:outline-2 focus-within:outline-offset-4 focus-within:outline-josi-red grid h-14 grid-cols-[1fr_auto] items-center rounded-lg bg-[#edf0ef]">
                <input
                  type={isPasswordVisible ? "text" : "password"}
                  autoComplete="current-password"
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                  className={`h-full min-w-0 rounded-lg border-0 bg-transparent px-5 font-semibold leading-none text-ink outline-none ${
                    isPasswordVisible
                      ? "text-base"
                      : "text-2xl tracking-[0.18em]"
                  }`}
                  aria-label="Password"
                  required
                />
                <button
                  type="button"
                  className="grid h-full w-14 place-items-center text-muted transition hover:text-ink"
                  aria-label={
                    isPasswordVisible ? "Hide password" : "Show password"
                  }
                  onClick={() => setIsPasswordVisible((current) => !current)}
                >
                  {isPasswordVisible ? <EyeOff size={23} /> : <Eye size={23} />}
                </button>
              </div>
            </label>

            <Link
              to="/forgot-password"
              className="focus-ring w-fit rounded text-base font-semibold text-josi-red hover:text-josi-darkRed"
            >
              Forgot password?
            </Link>

            {errorMessage && (
              <div className="rounded-lg border border-red-200 bg-red-50 p-3 text-sm font-semibold leading-relaxed text-josi-darkRed">
                {errorMessage}
              </div>
            )}

            <button
              type="submit"
              disabled={isSubmitting}
              className="focus-ring mt-5 inline-flex min-h-14 w-full items-center justify-center gap-2 rounded-full bg-josi-red px-6 text-base font-extrabold text-white shadow-soft transition hover:bg-josi-darkRed"
            >
              {isSubmitting ? (
                <Loader2 size={20} className="animate-spin" />
              ) : (
                <LockKeyhole size={20} />
              )}
              Sign in
            </button>
          </form>

          <div className="mt-8 border-t border-line pt-6 text-center">
            <p className="text-sm font-semibold text-muted">
              New to Josi?{" "}
              <Link
                to="/become-a-rider"
                className="focus-ring rounded font-extrabold text-josi-red hover:text-josi-darkRed"
              >
                Create an account
              </Link>
            </p>
          </div>
        </section>
      </div>
    </main>
  );
}
