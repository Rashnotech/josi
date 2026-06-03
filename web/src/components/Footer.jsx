import { Facebook, Instagram, Linkedin, MapPin, Twitter } from "lucide-react";
import logoUrl from "../assets/josi-logo.jpeg";

const footerColumns = [
  {
    title: "Company",
    links: ["About us", "Our offerings", "Newsroom", "Investors", "Blog", "Careers"],
  },
  {
    title: "Products",
    links: ["Ride", "Reserve", "Courier", "Josi for Business", "Josi Freight"],
  },
  {
    title: "Travel",
    links: ["Reserve", "Airports", "Cities"],
  },
];

function StoreBadge({ label }) {
  return (
    <span className="inline-flex min-h-9 items-center rounded-lg border border-white/30 px-3 text-xs font-bold text-white">
      {label}
    </span>
  );
}

export default function Footer() {
  return (
    <footer id="footer" className="bg-josi-black py-12 text-white sm:py-16">
      <div className="section-shell">
        <div className="flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="font-display text-3xl font-bold">
              <img src={logoUrl} alt="Josi Logo" style={{ width: "50px", height: "auto", display: "inline-block", verticalAlign: "middle" }} />
            </p>
            <a
              href="#account"
              className="focus-ring mt-6 inline-flex rounded-lg text-sm font-semibold text-white/70 hover:text-white"
            >
              Visit Help Center
            </a>
          </div>
        </div>

        <div className="mt-12 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          {footerColumns.map((column) => (
            <div key={column.title}>
              <h3 className="text-sm font-extrabold">{column.title}</h3>
              <ul className="mt-5 grid gap-3">
                {column.links.map((link) => (
                  <li key={link}>
                    <a
                      href="#ride"
                      className="focus-ring rounded text-sm font-medium text-white/70 hover:text-white"
                    >
                      {link}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="mt-12 flex flex-col gap-8 lg:flex-row lg:items-center lg:justify-between">
          <div className="flex items-center gap-5 text-white/80">
            <a className="focus-ring rounded" href="#footer" aria-label="Facebook">
              <Facebook size={18} />
            </a>
            <a className="focus-ring rounded" href="#footer" aria-label="Instagram">
              <Instagram size={18} />
            </a>
            <a className="focus-ring rounded" href="#footer" aria-label="LinkedIn">
              <Linkedin size={18} />
            </a>
            <a className="focus-ring rounded" href="#footer" aria-label="Twitter">
              <Twitter size={18} />
            </a>
          </div>
        </div>

        <div className="mt-8 flex flex-wrap gap-3">
          <StoreBadge label="Google Play" />
          <StoreBadge label="App Store" />
        </div>

        <div className="mt-10 flex flex-col gap-4 border-t border-white/10 pt-6 text-xs font-medium text-white/50 sm:flex-row sm:items-center sm:justify-between">
          <p>© 2026 Josi Transport and Logistics Nig. Ltd.</p>
          <div className="flex gap-5">
            <a href="#footer" className="hover:text-white">
              Privacy
            </a>
            <a href="#footer" className="hover:text-white">
              Accessibility
            </a>
            <a href="#footer" className="hover:text-white">
              Terms
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
}
