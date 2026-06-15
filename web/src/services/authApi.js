const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || "/api/v1").replace(
  /\/$/,
  "",
);
const DASHBOARD_BASE_URL = (
  import.meta.env.VITE_DASHBOARD_BASE_URL || ""
).replace(/\/$/, "");

export class ApiError extends Error {
  constructor(message, errors = {}, status = 0) {
    super(message);
    this.name = "ApiError";
    this.errors = errors;
    this.status = status;
  }
}

async function request(path, { method = "GET", token, body } = {}) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method,
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  let payload = {};
  try {
    payload = await response.json();
  } catch {
    payload = {};
  }

  if (!response.ok || payload.status === false) {
    throw new ApiError(
      payload.message || "Something went wrong. Please try again.",
      payload.errors || {},
      response.status,
    );
  }

  return {
    message: payload.message || "",
    data: payload.data || payload,
  };
}

export function registerAccount(payload) {
  return request("/auth/register", {
    method: "POST",
    body: payload,
  });
}

export function login(payload) {
  return request("/auth/login", {
    method: "POST",
    body: payload,
  });
}

export function forgotPassword(emailOrPhone) {
  return request("/auth/forgot-password", {
    method: "POST",
    body: { email_or_phone: emailOrPhone },
  });
}

export function verifyResetCode(emailOrPhone, code) {
  return request("/auth/verify-reset-code", {
    method: "POST",
    body: { email_or_phone: emailOrPhone, code },
  });
}

export function resetPassword(payload) {
  return request("/auth/reset-password", {
    method: "POST",
    body: payload,
  });
}

export function fetchCurrentUser(token) {
  return request("/auth/me", { token });
}

export function logout(token) {
  return request("/auth/logout", {
    method: "POST",
    token,
  });
}

export function firstValidationMessage(error) {
  if (!(error instanceof ApiError)) {
    return "Network error. Please check your connection and try again.";
  }

  const [firstField] = Object.keys(error.errors || {});
  const firstMessages = firstField ? error.errors[firstField] : null;
  if (Array.isArray(firstMessages) && firstMessages.length > 0) {
    return firstMessages[0];
  }

  return error.message;
}

export function redirectForRole(role, fallback = "/") {
  if (role === "pack_owner" || role === "fleet_owner") {
    return "/dashboard";
  }

  return fallback;
}

function dashboardPathForRole(role) {
  if (role === "admin" || role === "super_admin") {
    return "/admin";
  }

  return "/dashboard";
}

function absoluteUrlFromBase(baseUrl, path) {
  if (!baseUrl) {
    return "";
  }

  try {
    return `${new URL(baseUrl).origin}${path}`;
  } catch {
    return `${baseUrl}${path}`;
  }
}

export function dashboardUrlFromResponse(data) {
  const path = dashboardPathForRole(data?.user?.role || data?.role);
  const configuredDashboardUrl = absoluteUrlFromBase(DASHBOARD_BASE_URL, path);

  if (configuredDashboardUrl) {
    return configuredDashboardUrl;
  }

  try {
    const apiUrl = new URL(API_BASE_URL, window.location.origin);
    if (
      apiUrl.origin !== window.location.origin ||
      API_BASE_URL.startsWith("http")
    ) {
      return `${apiUrl.origin}${path}`;
    }
  } catch {}

  if (data?.dashboard_url) {
    try {
      const dashboardUrl = new URL(data.dashboard_url, window.location.origin);
      dashboardUrl.pathname = path;
      dashboardUrl.search = "";
      dashboardUrl.hash = "";

      return dashboardUrl.toString();
    } catch {
      return data.dashboard_url;
    }
  }

  return path;
}
