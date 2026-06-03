import { Link } from "react-router-dom";

const baseClasses =
  "focus-ring inline-flex min-h-11 items-center justify-center rounded-lg px-5 py-3 text-sm font-bold transition";

const variants = {
  dark: "bg-ink text-white hover:bg-neutral-800",
  light: "bg-paper text-ink hover:bg-line",
  red: "bg-josi-red text-white hover:bg-josi-darkRed",
};

export default function Button({
  children,
  to,
  className = "",
  variant = "dark",
  type = "button",
  ...props
}) {
  const classes = `${baseClasses} ${variants[variant]} ${className}`;

  if (to) {
    return (
      <Link to={to} className={classes} {...props}>
        {children}
      </Link>
    );
  }

  return (
    <button type={type} className={classes} {...props}>
      {children}
    </button>
  );
}
