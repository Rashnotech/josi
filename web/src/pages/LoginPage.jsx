import { useState } from "react";
import { Eye, EyeOff, LockKeyhole } from "lucide-react";
import { Link } from "react-router-dom";
import logoUrl from "../assets/josi-logo.jpeg";

export default function LoginPage() {
  const [isPasswordVisible, setIsPasswordVisible] = useState(false);

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

          <form className="auth-form mt-8 grid gap-5">
            <label className="grid gap-2.5">
              <span className="text-sm font-extrabold sm:text-base">
                Email or username <span className="text-josi-red">*</span>
              </span>
              <input
                type="text"
                autoComplete="username"
                className="focus-ring h-14 rounded-lg border-0 bg-[#edf0ef] px-5 text-base font-semibold text-ink outline-none"
                aria-label="Email or username"
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
                  className={`h-full min-w-0 rounded-lg border-0 bg-transparent px-5 font-semibold leading-none text-ink outline-none ${
                    isPasswordVisible
                      ? "text-base"
                      : "text-2xl tracking-[0.18em]"
                  }`}
                  aria-label="Password"
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

            <button
              type="submit"
              className="focus-ring mt-5 inline-flex min-h-14 w-full items-center justify-center gap-2 rounded-full bg-josi-red px-6 text-base font-extrabold text-white shadow-soft transition hover:bg-josi-darkRed"
            >
              <LockKeyhole size={20} />
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
