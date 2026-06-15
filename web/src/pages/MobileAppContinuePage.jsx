import { CheckCircle2, Smartphone } from "lucide-react";
import { Link, useLocation } from "react-router-dom";
import logoUrl from "../assets/josi_logo.png";

const roleLabels = {
  rider: "rider",
  courier: "courier",
};

export default function MobileAppContinuePage() {
  const location = useLocation();
  const role = roleLabels[location.state?.role] || "partner";
  const message =
    location.state?.message ||
    "Your account has been created. Continue your onboarding in the Josi mobile app.";

  return (
    <main className="min-h-screen bg-[#f4f6f5] px-5 py-7 text-ink sm:px-8 lg:py-10">
      <section className="mx-auto grid min-h-[calc(100vh-5rem)] w-full max-w-5xl items-center">
        <div className="grid overflow-hidden rounded-lg bg-white shadow-soft lg:grid-cols-[minmax(0,0.92fr)_minmax(0,1.08fr)]">
          <div className="relative hidden bg-josi-black p-8 text-white lg:block">
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_22%_18%,rgba(236,17,26,0.3),transparent_24rem)]" />
            <div className="relative grid h-full content-between gap-12">
              <Link
                to="/"
                className="focus-ring inline-flex w-fit rounded-lg"
                aria-label="Go to Josi home"
              >
                <img
                  src={logoUrl}
                  alt="Josi logo"
                  className="h-16 w-16 rounded-md object-contain"
                />
              </Link>

              <div>
                <span className="grid size-14 place-items-center rounded-full bg-josi-red text-white shadow-soft">
                  <Smartphone size={27} />
                </span>
                <h1 className="mt-6 font-display text-4xl font-bold leading-tight">
                  Continue in the Josi mobile app
                </h1>
                <p className="mt-4 max-w-sm text-sm font-semibold leading-relaxed text-white/70">
                  The mobile app is where {role}s finish onboarding, upload
                  documents, track approval, and start working.
                </p>
              </div>
            </div>
          </div>

          <div className="grid gap-7 p-6 sm:p-8 lg:p-10">
            <Link
              to="/"
              className="focus-ring inline-flex w-fit rounded-lg lg:hidden"
              aria-label="Go to Josi home"
            >
              <img
                src={logoUrl}
                alt="Josi logo"
                className="h-16 w-16 rounded-md object-contain"
              />
            </Link>

            <div className="grid gap-4">
              <span className="grid size-12 place-items-center rounded-full bg-green-100 text-green-700">
                <CheckCircle2 size={24} />
              </span>
              <div>
                <p className="text-xs font-extrabold uppercase text-josi-red">
                  Registration successful
                </p>
                <h2 className="mt-2 font-display text-3xl font-bold leading-tight sm:text-4xl">
                  Your {role} account is ready for the next step
                </h2>
                <p className="mt-4 text-base font-medium leading-relaxed text-muted">
                  {message}
                </p>
              </div>
            </div>

            <div className="grid gap-3 rounded-lg border border-line bg-paper p-4">
              <p className="text-sm font-extrabold text-ink">Next steps</p>
              <ul className="grid gap-2 text-sm font-semibold leading-relaxed text-muted">
                <li>Open or install the Josi mobile app on your phone.</li>
                <li>Sign in with the email or phone number you registered.</li>
                <li>Complete your profile, documents, and vehicle onboarding.</li>
              </ul>
            </div>

            <div className="flex flex-col gap-3 sm:flex-row">
              <Link
                to="/"
                className="focus-ring inline-flex min-h-12 items-center justify-center rounded-full bg-josi-red px-6 text-sm font-extrabold text-white shadow-soft transition hover:bg-josi-darkRed"
              >
                Back to home
              </Link>
              <Link
                to="/login"
                className="focus-ring inline-flex min-h-12 items-center justify-center rounded-full border border-line bg-white px-6 text-sm font-extrabold text-ink transition hover:border-josi-red hover:text-josi-red"
              >
                Go to sign in
              </Link>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
