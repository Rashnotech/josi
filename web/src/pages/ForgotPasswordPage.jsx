import { Link } from "react-router-dom";
import logoUrl from "../assets/josi-logo.jpeg";

export default function ForgotPasswordPage() {
  return (
    <main className="min-h-screen bg-white px-5 py-8 text-ink sm:px-8 lg:py-10">
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
            Forgot password?
          </h1>
          <p className="mx-auto mt-4 max-w-sm text-center text-base font-medium leading-relaxed text-muted">
            Enter your email and phone number, and we'll send you a link to
            reset your password.
          </p>

          <form className="auth-form mt-8 grid gap-5">
            <label className="grid gap-2.5">
              <span className="text-sm font-extrabold sm:text-base">
                Email <span className="text-josi-red">*</span>
              </span>
              <input
                type="email"
                autoComplete="email"
                className="focus-ring h-14 rounded-lg border-0 bg-[#edf0ef] px-5 text-base font-semibold text-ink outline-none"
                aria-label="Email"
              />
            </label>

            <label className="grid gap-2.5">
              <span className="text-sm font-extrabold sm:text-base">
                Phone number
              </span>
              <div className="grid grid-cols-[6rem_1fr] gap-3">
                <select
                  className="focus-ring h-14 rounded-lg border-0 bg-[#edf0ef] px-4 text-base font-bold text-ink outline-none"
                  aria-label="Country code"
                >
                  <option value="+234">+234</option>
                  <option value="+233">+233</option>
                  <option value="+44">+44</option>
                </select>
                <input
                  type="tel"
                  autoComplete="tel"
                  className="focus-ring h-14 rounded-lg border-0 bg-[#edf0ef] px-5 text-base font-semibold text-ink outline-none"
                  aria-label="Phone number"
                />
              </div>
            </label>

            <button
              type="submit"
              className="focus-ring mt-5 inline-flex min-h-14 w-full items-center justify-center rounded-full bg-josi-red px-6 text-base font-extrabold text-white shadow-soft transition hover:bg-josi-darkRed"
            >
              Reset password
            </button>

            <Link
              to="/login"
              className="focus-ring inline-flex min-h-14 w-full items-center justify-center rounded-full bg-[#edf0ef] px-6 text-base font-extrabold text-ink transition hover:bg-line"
            >
              Return to sign in
            </Link>
          </form>
        </section>
      </div>
    </main>
  );
}
