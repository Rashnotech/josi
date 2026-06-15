import { useState } from "react";
import { CheckCircle2, Loader2 } from "lucide-react";
import { Link } from "react-router-dom";
import logoUrl from "../assets/josi-logo.png";
import {
  firstValidationMessage,
  forgotPassword,
  resetPassword,
  verifyResetCode,
} from "../services/authApi.js";

export default function ForgotPasswordPage() {
  const [step, setStep] = useState("request");
  const [emailOrPhone, setEmailOrPhone] = useState("");
  const [code, setCode] = useState("");
  const [password, setPassword] = useState("");
  const [passwordConfirmation, setPasswordConfirmation] = useState("");
  const [statusMessage, setStatusMessage] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function submitRequest(event) {
    event.preventDefault();
    await submit(async () => {
      const { message } = await forgotPassword(emailOrPhone);
      setStatusMessage(message);
      setStep("verify");
    });
  }

  async function submitVerify(event) {
    event.preventDefault();
    await submit(async () => {
      await verifyResetCode(emailOrPhone, code);
      setStatusMessage("Reset code verified successfully.");
      setStep("reset");
    });
  }

  async function submitReset(event) {
    event.preventDefault();
    await submit(async () => {
      const { message } = await resetPassword({
        email_or_phone: emailOrPhone,
        code,
        password,
        password_confirmation: passwordConfirmation,
      });
      setStatusMessage(message || "Password reset successful.");
      setStep("done");
    });
  }

  async function submit(callback) {
    setIsSubmitting(true);
    setErrorMessage("");
    setStatusMessage("");
    try {
      await callback();
    } catch (error) {
      setErrorMessage(firstValidationMessage(error));
    } finally {
      setIsSubmitting(false);
    }
  }

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
            Enter your email or phone number and use the code sent to your
            inbox to reset access.
          </p>

          {statusMessage && (
            <div className="mt-6 flex items-start gap-3 rounded-lg border border-green-200 bg-green-50 p-3 text-sm font-semibold leading-relaxed text-green-800">
              <CheckCircle2 size={19} className="mt-0.5 shrink-0" />
              <span>{statusMessage}</span>
            </div>
          )}

          {errorMessage && (
            <div className="mt-6 rounded-lg border border-red-200 bg-red-50 p-3 text-sm font-semibold leading-relaxed text-josi-darkRed">
              {errorMessage}
            </div>
          )}

          {step === "request" && (
            <form className="auth-form mt-8 grid gap-5" onSubmit={submitRequest}>
              <TextInput
                label="Email or phone"
                value={emailOrPhone}
                onChange={setEmailOrPhone}
                autoComplete="username"
              />
              <SubmitButton label="Send reset code" loading={isSubmitting} />
              <ReturnLink />
            </form>
          )}

          {step === "verify" && (
            <form className="auth-form mt-8 grid gap-5" onSubmit={submitVerify}>
              <TextInput
                label="Reset code"
                value={code}
                onChange={setCode}
                inputMode="numeric"
                maxLength={6}
              />
              <SubmitButton label="Verify code" loading={isSubmitting} />
              <button
                type="button"
                className="focus-ring inline-flex min-h-14 w-full items-center justify-center rounded-full bg-[#edf0ef] px-6 text-base font-extrabold text-ink transition hover:bg-line"
                onClick={() => setStep("request")}
              >
                Change email or phone
              </button>
            </form>
          )}

          {step === "reset" && (
            <form className="auth-form mt-8 grid gap-5" onSubmit={submitReset}>
              <TextInput
                label="New password"
                value={password}
                onChange={setPassword}
                type="password"
                autoComplete="new-password"
              />
              <TextInput
                label="Confirm password"
                value={passwordConfirmation}
                onChange={setPasswordConfirmation}
                type="password"
                autoComplete="new-password"
              />
              <SubmitButton label="Reset password" loading={isSubmitting} />
            </form>
          )}

          {step === "done" && (
            <div className="mt-8">
              <ReturnLink label="Back to sign in" />
            </div>
          )}
        </section>
      </div>
    </main>
  );
}

function TextInput({
  label,
  value,
  onChange,
  type = "text",
  autoComplete,
  inputMode,
  maxLength,
}) {
  return (
    <label className="grid gap-2.5">
      <span className="text-sm font-extrabold sm:text-base">
        {label} <span className="text-josi-red">*</span>
      </span>
      <input
        type={type}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        required
        autoComplete={autoComplete}
        inputMode={inputMode}
        maxLength={maxLength}
        className="focus-ring h-14 rounded-lg border-0 bg-[#edf0ef] px-5 text-base font-semibold text-ink outline-none"
      />
    </label>
  );
}

function SubmitButton({ label, loading }) {
  return (
    <button
      type="submit"
      disabled={loading}
      className="focus-ring mt-5 inline-flex min-h-14 w-full items-center justify-center gap-2 rounded-full bg-josi-red px-6 text-base font-extrabold text-white shadow-soft transition hover:bg-josi-darkRed disabled:cursor-not-allowed disabled:opacity-70"
    >
      {loading && <Loader2 size={19} className="animate-spin" />}
      {label}
    </button>
  );
}

function ReturnLink({ label = "Return to sign in" }) {
  return (
    <Link
      to="/login"
      className="focus-ring inline-flex min-h-14 w-full items-center justify-center rounded-full bg-[#edf0ef] px-6 text-base font-extrabold text-ink transition hover:bg-line"
    >
      {label}
    </Link>
  );
}
