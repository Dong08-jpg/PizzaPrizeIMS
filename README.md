# PIZZA PRIZE
## A Web-Based Inventory and Sales Management System for a Pizza Shop

*"Baratu na! Namit pa!"*

A web application built in **Java using Object-Oriented Programming**. The backend uses only the JDK (built-in `com.sun.net.httpserver`), so there is **no Maven, no Tomcat and no database to install**. The front end is HTML, CSS and JavaScript in the shop's logo colors: black, yellow and red.

---

## 1. How to run

**Requirement:** JDK 17 or newer (tested on JDK 21). Check with `java -version`.

| OS | Steps |
|---|---|
| Windows | Double-click **`run.bat`** |
| Mac / Linux | `./run.sh` |
| NetBeans / IntelliJ / Eclipse | Open the folder as a project, set `src` as the source folder, run `com.pizzaprize.Main` **with the project folder as the working directory** (so it can find `web/` and `data/`) |

Then open **http://localhost:8080** in your browser.

| Account | Username | Password | Access |
|---|---|---|---|
| Owner / Admin | `admin` | `admin123` | All modules |
| Cashier | `cashier` | `cashier123` | Dashboard, POS, today's Sales Reports only; no Expenses History access |

On the very first run (empty `data/` folder) the system creates the two accounts above, a starter ingredient list
with a few starter recipes, and the shop's real menu (`service/MenuCatalog.java`: pizzas in 5 sizes, combo meals,
silog, chicken, soup, noodles & pasta — spaghetti, carbonara and palabok —, mac 'n cheese and spuds). It does **not** create any sales: every transaction in the
dashboard and reports comes from a real checkout.

**Data upgrades and backups.** Startup takes a daily snapshot of `data/` in `data/backups/daily-YYYY-MM-DD/`
(one per date, excluding the backups folder itself); the server also snapshots again once a day while running and
keeps the most recent 14 daily backups. Ordered data migrations are tracked in the single `data/schema-version`
file. Existing `*.done` migration markers are mapped to their equivalent version and then removed, so completed
upgrades do not run again. Migration v4 adds the customer name to saved sales, backs up the data first, and assigns
`Walk-in` to older sales. Migration v6 introduces SC/PWD ID details for new discounted sales; older sales remain
unchanged because their identification details cannot be recovered. Migration v7 assigns Dine-in to existing sales.
The earlier dough migrations (v9 merge into portions, v10 restore of the five per-size items) no longer run. A pending
data update (v11) is shown to an Admin on the Dashboard; it changes data only when the Admin selects **Back up & run**,
makes a fresh backup first, and records the actual Admin name. It sets Drinks to DIRECT_STOCK (each drink linked to its
existing stock item, its recipe row removed) and keeps pizza dough as **one** ingredient, **Pizza Dough**, in whole
grams: an older "Pizza Dough Portion", per-size dough piece or "Pizza Dough" counted in kg is converted (1 kg = 1000 g;
a portion or piece by its grams per portion) and archived, never deleted, so its stock history and past sales remain.
Pizzas lose their dough recipe rows (Dough per Size supplies the dough); other recipes such as a combo's pizza slice
keep their dough in whole grams. Flour or yeast used only by pizzas is taken out of the pizza recipes and archived.
Sales are not changed.
The migrations retain the existing menu setup: they add missing menu ingredients and
starter recipes without changing existing ingredients or recipes, merge **Pasta** and **Palabok** into
**Noodles & Pasta** and add Carbonara, then remove obsolete Regular pizza sizes. Each data-changing menu migration
first makes its own labeled backup in `data/backups/`. Ingredient quantities, opening stock and costs remain
starting estimates; adjust them on the Inventory and Menu / Products pages.

To reset everything, stop the server and delete the `data/` folder (this permanently deletes all records).

---

## 2. Features (system modules)

1. **Login and role-based access.** Admin and Cashier accounts. Passwords are stored as SHA-256 hashes. The sidebar only shows the modules a role may open, and the server checks the permission on every request.
2. **Dashboard.** Admins see all-time and monthly sales, product and stock summaries, sales trends, top sellers, recent transactions (with receipt view) and low-stock alerts. Cashiers see only today's revenue and orders, today's cash and e-wallet collections, today's recent transactions (with receipt view) and low-stock ingredient names.
3. **Point of Sale (POS).** Category rail and menu search, product pictures, one-tap size buttons (pizzas: Solo to Family), add-ons / toppings listed only under Pizza (any category whose name contains "add-on" or "topping", e.g. "Pizza Add-ons"), quantity controls, Dine-in / Take-out selection, a required customer-name step (up to 50 characters, with a Walk-in option), Senior Citizen/PWD 20% discount, Cash/GCash/Maya payment, quick-cash buttons, change computation and a printable 80 mm receipt. Orders can be parked with a label, listed, resumed or discarded; held orders are kept in server memory per user and cleared when the server restarts. The menu knows the ingredient stock: items that cannot be made are disabled, items running low show how many are left, and the cart will not take more than the stock on hand.
4. **Menu / Products.** Search, category and status filters (available, low / out of stock, hidden, recipe not set) and pagination. Items with sizes (every pizza flavor, and e.g. Lomi Solo/Group) are one row with their size prices; **View** shows prices, food cost, margin, how many can still be made and the inventory tracking setup; **Edit** opens the size panel (pizzas always list Solo, Medium, Large, XL and Family; there is no Regular pizza size); **Delete** asks for confirmation. Each size is its own product, named like "Hawaiian Pizza (Large)", with its own price and availability. **Add pizza flavor** creates all sizes at once. Categories use RECIPE (ingredient builder), DIRECT_STOCK (one linked stock item) or NONE (no inventory deduction); Drinks uses DIRECT_STOCK. An optional **product picture** is resized in the browser, checked on the server and stored in `data/product-images/`. Items can be hidden from or shown on the POS in one click. **Manage categories** (beside Reset) adds and deletes categories; a category that still has items cannot be deleted until they are moved or deleted. New categories appear at once in the category filter, the product forms and the Point of Sale (which reloads the menu whenever it is opened or brought back into view). Categories are stored in `data/categories.dat`; on startup every category already used by a product is added to the list automatically.
5. **Inventory.** Stock is **separated by the Point of Sale categories**: every ingredient belongs to one category (Pizza, Silog Meals, Soup…), and a category bar like the POS rail shows each category's stock with how many items need restocking. Choosing a category scopes the summary figures, the restock warning, the stock levels and the stock movement history. An ingredient used by several categories (e.g. Rice in Silog, Chicken Rice Meals, Combo Meals and Soup) is kept once and also listed, marked "shared with", under every category whose recipes use it. Recipe ingredient lists on the Menu page are grouped by category. Ingredient stock with level bars, reorder levels, unit cost and stock value; low-stock warning banner. **Stock In** records the amount paid, supplier, payment method and reference, creates one linked expense, and updates unit cost from the paid amount and converted received quantity. **Stock Out** (spoilage / wastage, with a reason) shows the balance before and after. Stock is kept to 4 decimal places so repeated deductions never drift. An ingredient can record an optional **grams per portion**, shown under its name (e.g. "1 portion = 150 g").
   **Pizza dough** is made in one batch and kept as **one** ingredient, **Pizza Dough**, in whole grams (shown as "4,250 g (4.25 kg)"). Admins restock it in grams after making a batch (e.g. +5000 g for a 5 kg batch); its name and units cannot be changed and it cannot be deleted. Its minimum level (low-stock warning) is set in grams. **Dough per Size** (Admin only, sidebar → Operations) sets how many grams one pizza of each size uses; nothing is assumed, and a size without grams cannot be sold (the POS and the server show a clear message). Pizza recipes do not list the dough themselves.
6. **Automatic stock deduction.** At checkout, RECIPE products deduct each recipe ingredient × quantity sold, plus for every pizza the Pizza Dough grams for its size × quantity; DIRECT_STOCK products deduct one unit per item from their linked stock item, and NONE products do not deduct inventory. The stock check and deduction happen under one lock, so a sale is **rejected** if tracked stock is short ("Not enough dough" for Pizza Dough, covering all pizzas in the order) and stock never goes negative. Each dough deduction is its own stock movement naming the pizza and size, e.g. "Hawaiian Pizza (Large) × 2 (400 g each)".
7. **Duplicate-order protection.** The POS sends a unique reference with each order. If the same order is submitted twice (double click, slow network, retry), the server returns the sale already recorded instead of charging or deducting twice.
8. **Stock movement history.** An audit trail of every stock in, stock out and sale, filterable by type, ingredient and date, with pagination.
9. **Sales reports.** Admins can view daily, weekly, monthly or custom periods, including revenue, orders, average order, gross sales, gross profit from recipe costs, discounts, payment/order/category breakdowns, cashier performance, best sellers and transactions. Cashiers are restricted to today's revenue, orders, cash and e-wallet collections, and today's transactions with receipt viewing/reprinting; period selectors and exports are not available. Transaction history and receipts include the customer name and order type. Product name, size, category, price and recipe cost are snapshotted for each new sale, keeping reports stable after menu edits. Admin **Print report** produces an A4 report; Admin **Export CSV** downloads the data. Admins also get a summary box at the top: **Gross Sales** (completed orders after SC/PWD discounts, voided orders excluded) − **Total Expenses** = **Net Sales** (green when positive, red when negative), plus an **Expenses** table (date, description / category, amount, recorded by, total) for the same period. Both are included in the printed report and the CSV. These money totals are calculated on the server with `BigDecimal`, and the server never sends expenses or net totals to a Cashier.
10. **User management.** Add users, edit name and role, reset passwords, enable / disable and delete accounts, plus a role-permission table. The system always keeps at least one active Admin, and nobody can delete, disable or demote their own account.
11. **Audit log.** Admin-only, searchable history of product and price changes, user changes, voids, stock adjustments, migrations and expense corrections. It shows who made each change, when, and the old and new values; details are clamped to two lines with a **View** dialog for the full semicolon-separated change list. Entries are stored in `data/audit.dat`.
12. **Expenses History.** Admin-only records of ingredient and other item expenses, newest first, with date, ingredient, supplier, payment method and reference filters, pagination, filtered-period totals and the five ingredients with the highest spend. Admins can record expenses, optionally link one to a Stock In movement, export CSV and print an A4 report. Corrections are limited to amount, supplier and note, require a reason and create an audit entry; expenses cannot be deleted. Cashiers do not see the menu item, and all `/api/expenses` requests from a Cashier return 403.
13. **Responsive layout.** Works on desktop, tablet and phone: the sidebar becomes a slide-out menu, tables become stacked rows, and the POS shows a floating "View order" bar.

---

## 3. System architecture (layered)

```
Browser (HTML/CSS/JS)
      │  JSON over HTTP
      ▼
web/         ApiHandler → Router → Controllers   (presentation layer)
      ▼
service/     AuthService, ProductService, CategoryService,
             InventoryService, SalesService, ExpenseService, AuditService,
             ReportService                         (business logic layer)
      ▼
repository/  Repository<T> ← FileRepository<T>     (data access layer)
      ▼
data/*.dat   (persistent storage)
```

### Project structure
```
PizzaPrizeIMS/
├── run.bat / run.sh
├── src/com/pizzaprize/
│   ├── Main.java                  entry point, wires all objects together
│   ├── model/                     Entity, User, Admin, Cashier, Product, Category, RecipeItem,
│   │                              Ingredient, Sale, Expense, SaleItem, StockMovement, AuditEntry, enums
│   ├── exception/                 AppException + 5 subclasses
│   ├── repository/                Repository<T> (interface), FileRepository<T>
│   ├── service/                   business logic, ExpenseService, AuditService + DataSeeder
│   ├── util/Json.java             JSON reader/writer
│   └── web/                       HTTP server, router, controllers
└── web/
    ├── index.html                 page shell: login, sidebar, top bar, dialogs
    ├── css/style.css              theme (black / dark gray, yellow, red) and responsive layout
    ├── img/logo.jpg
    └── js/
        ├── core.js                shared helpers: API client, icons, toasts, dialogs, pagination, receipt
        ├── charts.js              dependency-free bar charts with tooltips
        ├── app.js                 login, role-based sidebar, page routing
        └── pages/                 dashboard.js, pos.js, products.js, inventory.js, dough.js, reports.js, expenses.js, users.js, audit.js
```

---

## 4. OOP concepts applied (for your defense)

| Concept | Where to find it in the code |
|---|---|
| **Encapsulation** | All fields are `private`. `Ingredient` stock can only change through `addStock()` / `deductStock()`, which validate the quantity. `Sale` totals are computed by methods, not stored. |
| **Inheritance** | `Entity` → `User`, `Product`, `Category`, `Ingredient`, `Sale`, `StockMovement`, `AuditEntry`. `User` → `Admin`, `Cashier`. `AppException` → `ValidationException`, `InsufficientStockException`, etc. `BaseController` → the controllers. |
| **Abstraction** | Abstract classes `Entity`, `User`, `AppException` and `BaseController`. Interfaces `Repository<T>`, `JsonSerializable` and `Route`. |
| **Polymorphism** | `user.canAccess(module)` behaves differently for `Admin` and `Cashier`. `exception.getStatus()` returns a different HTTP code for each exception type. `toJson()` is overridden by every model. |
| **Composition** | A `Product` *has* `RecipeItem`s, and a `Sale` *has* `SaleItem`s. Services are built from repositories. |
| **Generics** | `Repository<T extends Entity>` and `FileRepository<T>` work for every entity type. |
| **Interfaces / lambdas** | Each `Route` is a functional interface, and routes are registered as lambdas. |
| **Exception handling** | Custom business-rule exceptions (insufficient stock, insufficient payment, access denied) are thrown and converted to error messages. |
| **Design patterns** | Repository, Factory Method (`AuthService.createUser`), Front Controller (`ApiHandler`) and a layered (MVC-style) architecture. |

---

## 5. REST API summary

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/api/auth/login`, `/api/auth/logout` | Log in / log out |
| GET | `/api/auth/me` | Current user |
| GET/POST/PUT/DELETE | `/api/products[/{id}]` | Manage menu (the list includes `servings` and `stockStatus`) |
| POST/PUT | `/api/product-groups` | Add / rename all sizes of an item |
| PUT | `/api/product-groups/availability` | Show or hide products on the POS |
| GET/POST | `/api/categories` | List categories (with `productCount`) / add a category |
| DELETE | `/api/categories/{id}` | Delete an empty category (refused while it has products) |
| GET/POST/PUT/DELETE | `/api/ingredients[/{id}]` | Manage ingredients (optional `gramsPerPortion`; `GET ?archived=only` lists archived ingredients, which cannot be changed) |
| POST | `/api/ingredients/{id}/stock-in` | Receive stock (quantity, amountPaid, supplier, paymentMethod, reference, note); creates a linked expense and updates unit cost |
| POST | `/api/ingredients/{id}/stock-out` | Adjust stock |
| GET | `/api/stock-movements?type=&ingredientId=&from=&to=&limit=`, `/api/stock-movements/{id}` | Stock history and one movement (dough deductions include `productName`, `productSize`, `productQuantity`) |
| GET/PUT | `/api/dough-sizes` | Admin only: Pizza Dough stock and grams per pizza size; PUT `{"sizes":[{"size":"Large","grams":300}],"minimumGrams":5000}` (blank grams = not set) |
| POST | `/api/sales` | Checkout (`clientRef` prevents duplicate orders) |
| GET | `/api/sales/{id}` | One sale (receipt) |
| GET | `/api/reports/dashboard`, `/api/reports/sales?from=&to=` | Reports (sales reports include gross profit, category profit and snapshot-based best sellers; Admin sales reports also include `netSummary` and `expenses`) |
| GET | `/api/expenses?from=&to=&ingredientId=&supplier=&paymentMethod=&reference=&page=&pageSize=` | Admin-only filtered expense history, pagination and matching-period summary |
| GET | `/api/expenses/export`, `/api/expenses/suppliers` | Admin-only matching expense data for CSV and supplier filter options |
| GET/POST | `/api/expenses[/{id}]` | Admin-only expense details / record an expense |
| PUT | `/api/expenses/{id}` | Admin-only correction of amount, supplier and note (reason required; audited) |
| GET/POST | `/api/users` | List / add user accounts |
| PUT | `/api/users/{id}`, `/api/users/{id}/status`, `/api/users/{id}/password` | Edit name & role, enable / disable, reset password |
| DELETE | `/api/users/{id}` | Delete user |

---

## 6. Current limitations

- Older sales remain readable and keep their recorded selling prices. In sales analytics, lines without full snapshots fall back to current product names, categories and recipe costs; historical gross profit for those lines is therefore an estimate. Reprinted legacy receipts retain the details originally recorded on them.
- Gross profit is sales less recipe ingredient cost, before order discounts, labor, rent, tax and other operating costs.
- Daily backups are stored on the same machine and disk as `data/`; copy the backup folder elsewhere for disaster recovery.

## 7. Possible enhancements (for "Recommendations")

- Replace `FileRepository` with a `MySqlRepository` (JDBC) that implements the same `Repository<T>` interface. No service code needs to change.
- Add salted password hashing (e.g. PBKDF2 or BCrypt).
- Add supplier and purchase-order modules, ingredient expiry tracking, online ordering and BIR-compliant receipts.
