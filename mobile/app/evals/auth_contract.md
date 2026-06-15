# Customer Auth Integration Contract

Gate checks for customer auth work:

- Customer registration posts to `/auth/register/customer`.
- The mobile UI field `fullName` is never sent as `full_name`.
- `fullName` is split into `first_name` and `last_name`; a one-word name omits `last_name`.
- The current Laravel validator still requires `name`, so mobile sends `name` as the joined split name.
- Login, forgot password, verify reset code, and reset password use `identifier` for email or phone.
- Auth tokens are stored through `TokenStorage`; passwords are never stored.
- Customer routes under `/customer/*` and `/edit-profile` require an authenticated customer.
- Customer dashboard empty states are shown when recent locations, saved addresses, or trips have no backend endpoint/data.
