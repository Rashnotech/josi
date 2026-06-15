import { useEffect, useRef, useState } from "react";
import { Link, NavLink, useLocation } from "react-router-dom";
import { Menu, X } from "lucide-react";
import RegisterDropdown from "./RegisterDropdown.jsx";
import Logo from '../assets/josi_logo.png';

const menuLinks = [
  { label: "Home", href: "/" },
  { label: "Ride", href: "/#ride" },
  { label: "Reserve", href: "/#reserve" },
  { label: "Business", href: "/#business" },
];

export default function Header() {
  const [isRegisterOpen, setIsRegisterOpen] = useState(false);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const location = useLocation();
  const registerRef = useRef(null);

  useEffect(() => {
    setIsRegisterOpen(false);
    setIsMenuOpen(false);
  }, [location.pathname]);

  useEffect(() => {
    function handlePointerDown(event) {
      if (
        registerRef.current &&
        !registerRef.current.contains(event.target)
      ) {
        setIsRegisterOpen(false);
      }
    }

    document.addEventListener("pointerdown", handlePointerDown);
    return () => document.removeEventListener("pointerdown", handlePointerDown);
  }, []);

  return (
    <header className="sticky top-0 z-50 bg-josi-black text-white">
      <div className="section-shell flex h-16 items-center justify-between">
        <Link
          to="/"
          className="focus-ring font-display text-[2rem] font-bold leading-none text-white"
          aria-label="Josi home"
        >
          <img src={Logo} alt="Josi Logo" style={{ width: "50px", height: "auto" }} />
        </Link>

        <div className="relative flex items-center gap-2 sm:gap-3" ref={registerRef}>
          <button
            type="button"
            className="focus-ring rounded-full bg-white px-5 py-2.5 text-sm font-bold text-ink transition hover:bg-paper"
            aria-expanded={isRegisterOpen}
            aria-controls="register-dropdown"
            onClick={() => {
              setIsRegisterOpen((current) => !current);
              setIsMenuOpen(false);
            }}
          >
            Register
          </button>

          <button
            type="button"
            className="focus-ring grid size-11 place-items-center rounded-full bg-white/10 text-white transition hover:bg-white/20"
            aria-label={isMenuOpen ? "Close menu" : "Open menu"}
            aria-expanded={isMenuOpen}
            onClick={() => {
              setIsMenuOpen((current) => !current);
              setIsRegisterOpen(false);
            }}
          >
            {isMenuOpen ? <X size={21} /> : <Menu size={22} />}
          </button>

          {isRegisterOpen && <RegisterDropdown id="register-dropdown" />}
        </div>
      </div>

      {isMenuOpen && (
        <nav className="border-t border-white/10 bg-josi-black">
          <div className="section-shell grid gap-1 py-4">
            {menuLinks.map((link) => (
              <NavLink
                key={link.label}
                to={link.href}
                className="focus-ring rounded-lg px-1 py-3 text-base font-semibold text-white/80 hover:text-white"
              >
                {link.label}
              </NavLink>
            ))}
          </div>
        </nav>
      )}
    </header>
  );
}
