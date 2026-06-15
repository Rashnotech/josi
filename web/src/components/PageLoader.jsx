import Logo from '../assets/josi_logo.png';

export default function PageLoader({ isVisible }) {
  return (
    <div
      className={`loading-overlay ${isVisible ? "is-visible" : ""}`}
      role="status"
      aria-live="polite"
      aria-hidden={!isVisible}
    >
      <div className="loading-card">
        <div className="loading-mark">
          <img src={Logo} alt="Josi Logo" style={{ width: "50px", height: "auto" }} />
        </div>
        <div className="loading-spinner" aria-hidden="true" />
      </div>
    </div>
  );
}
