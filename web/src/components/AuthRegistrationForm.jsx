import { useState } from "react";
import { Loader2 } from "lucide-react";
import { useNavigate } from "react-router-dom";
import {
  firstValidationMessage,
  registerAccount,
} from "../services/authApi.js";

const initialValues = {
  first_name: "",
  last_name: "",
  email: "",
  phone: "",
  password: "",
  password_confirmation: "",
  business_name: "",
  vehicle_count: "",
};

export default function AuthRegistrationForm({
  role,
  title,
  submitLabel,
  business = false,
}) {
  const [values, setValues] = useState(initialValues);
  const [errorMessage, setErrorMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const navigate = useNavigate();
  const twoColumnRowClass =
    "grid min-w-0 gap-4 sm:grid-cols-[minmax(0,1fr)_minmax(0,1fr)] sm:gap-x-5 sm:gap-y-4";

  function updateValue(event) {
    const { name, value } = event.target;
    setValues((current) => ({ ...current, [name]: value }));
  }

  async function handleSubmit(event) {
    event.preventDefault();
    setIsSubmitting(true);
    setErrorMessage("");

    try {
      const payload = {
        role,
        first_name: values.first_name,
        last_name: values.last_name,
        email: values.email,
        phone: values.phone,
        password: values.password,
        password_confirmation: values.password_confirmation,
        business_phone: values.phone,
      };

      if (business) {
        payload.business_name = values.business_name;
        payload.vehicle_count = values.vehicle_count;
      }

      const { data, message } = await registerAccount(payload);

      if (
        role === "pack_owner" ||
        role === "fleet_owner" ||
        data.login_required
      ) {
        navigate(data.redirect_to || "/login", {
          replace: true,
          state: {
            message:
              message ||
              "Account created successfully. Please sign in to access your dashboard.",
          },
        });
        return;
      }

      navigate("/continue-in-mobile-app", {
        replace: true,
        state: {
          role,
          message:
            message ||
            "Account created successfully. Continue your onboarding in the Josi mobile app.",
        },
      });
    } catch (error) {
      setErrorMessage(firstValidationMessage(error));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form
      className="w-full min-w-0 max-w-full overflow-hidden rounded-lg bg-white p-5 shadow-menu sm:p-6"
      onSubmit={handleSubmit}
    >
      <h2 className="font-display text-2xl font-bold text-ink">{title}</h2>

      {errorMessage && (
        <div className="mt-4 rounded-lg border border-red-200 bg-red-50 p-3 text-sm font-semibold leading-relaxed text-josi-darkRed">
          {errorMessage}
        </div>
      )}

      <div className="mt-5 grid gap-5">
        <div className={twoColumnRowClass}>
          <TextInput
            label="First name"
            name="first_name"
            value={values.first_name}
            onChange={updateValue}
            required
          />
          <TextInput
            label="Last name"
            name="last_name"
            value={values.last_name}
            onChange={updateValue}
            required
          />
        </div>

        {business && (
          <div className={twoColumnRowClass}>
            <TextInput
              label="Pack name"
              name="business_name"
              value={values.business_name}
              onChange={updateValue}
              required
            />
            <label className="grid gap-2">
              <span className="text-xs font-extrabold text-muted">
                Vehicles in your pack <span className="text-josi-red">*</span>
              </span>
              <select
                name="vehicle_count"
                value={values.vehicle_count}
                onChange={updateValue}
                required
                className="focus-ring h-12 w-full min-w-0 rounded-lg border border-line bg-paper px-4 font-normal text-ink"
              >
                <option value="">Select vehicle range</option>
                <option value="2">2 - 10</option>
                <option value="11">11 - 25</option>
                <option value="26">26 - 50</option>
                <option value="51">51+</option>
              </select>
            </label>
          </div>
        )}

        <div className={twoColumnRowClass}>
          <TextInput
            label="Email address"
            name="email"
            value={values.email}
            onChange={updateValue}
            required
            type="email"
            autoComplete="email"
          />
          <TextInput
            label="Phone number"
            name="phone"
            value={values.phone}
            onChange={updateValue}
            required
            type="tel"
            autoComplete="tel"
          />
        </div>

        <div className={twoColumnRowClass}>
          <TextInput
            label="Password"
            name="password"
            value={values.password}
            onChange={updateValue}
            required
            type="password"
            autoComplete="new-password"
          />

          <TextInput
            label="Confirm password"
            name="password_confirmation"
            value={values.password_confirmation}
            onChange={updateValue}
            required
            type="password"
            autoComplete="new-password"
          />
        </div>
      </div>

      <button
        type="submit"
        disabled={isSubmitting}
        className="focus-ring mt-5 inline-flex min-h-12 w-full items-center justify-center gap-2 rounded-full bg-josi-red px-5 text-sm font-extrabold text-white shadow-soft transition hover:bg-josi-darkRed disabled:cursor-not-allowed disabled:opacity-70"
      >
        {isSubmitting && <Loader2 size={18} className="animate-spin" />}
        {submitLabel}
      </button>
    </form>
  );
}

function TextInput({
  label,
  name,
  value,
  onChange,
  type = "text",
  required = false,
  autoComplete,
}) {
  return (
    <label className="grid min-w-0 gap-2">
      <span className="text-xs font-extrabold text-muted">
        {label}
        {required && <span className="text-josi-red"> *</span>}
      </span>
      <input
        name={name}
        value={value}
        onChange={onChange}
        className="focus-ring h-12 w-full min-w-0 rounded-lg border border-line bg-paper px-4 font-normal text-ink"
        type={type}
        required={required}
        autoComplete={autoComplete}
      />
    </label>
  );
}
