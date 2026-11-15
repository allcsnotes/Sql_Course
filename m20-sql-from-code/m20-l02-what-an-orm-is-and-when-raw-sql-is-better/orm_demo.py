import getpass
import re

from sqlalchemy import ForeignKey, create_engine, event, select, text
from sqlalchemy.orm import (DeclarativeBase, Mapped, Session, mapped_column,
                            relationship, selectinload)


class Base(DeclarativeBase):
    pass


class MenuItem(Base):
    __tablename__ = "menu_items"
    item_id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str]
    price: Mapped[int]


class Order(Base):
    __tablename__ = "orders"
    order_id: Mapped[int] = mapped_column(primary_key=True)
    branch_id: Mapped[int]
    items: Mapped[list["OrderItem"]] = relationship()


class OrderItem(Base):
    __tablename__ = "order_items"
    order_id: Mapped[int] = mapped_column(ForeignKey("orders.order_id"), primary_key=True)
    item_id: Mapped[int] = mapped_column(primary_key=True)
    qty: Mapped[int]


password = getpass.getpass("Database password: ")
engine = create_engine("postgresql+psycopg://postgres@localhost/chai_corner",
                       connect_args={"password": password})

sent = []


@event.listens_for(engine, "before_cursor_execute")
def show_sql(conn, cursor, statement, params, context, executemany):
    sent.append(statement)
    print("   SQL >", re.sub(r"\s+", " ", statement).strip(), params)


with Session(engine) as session:

    print("\n--- 1. ORM: items under 40, cheapest first ---")
    stmt = select(MenuItem).where(MenuItem.price < 40).order_by(MenuItem.price)
    for item in session.scalars(stmt):
        print(item.name, item.price)

    print("\n--- 2. N+1: 5 orders, then each order's items ---")
    sent.clear()
    orders = session.scalars(select(Order).order_by(Order.order_id).limit(5)).all()
    for o in orders:
        print("order", o.order_id, "->", len(o.items), "item(s)")
    print("queries sent:", len(sent))

    session.expunge_all()
    print("\n--- 3. fix: selectinload ---")
    sent.clear()
    orders = session.scalars(select(Order).order_by(Order.order_id).limit(5)
                             .options(selectinload(Order.items))).all()
    for o in orders:
        print("order", o.order_id, "->", len(o.items), "item(s)")
    print("queries sent:", len(sent))

    print("\n--- 4. raw SQL: top 3 items by cups, with RANK ---")
    rows = session.execute(text("""
        SELECT m.name, SUM(oi.qty) AS cups,
               RANK() OVER (ORDER BY SUM(oi.qty) DESC) AS rnk
        FROM order_items oi JOIN menu_items m ON m.item_id = oi.item_id
        GROUP BY m.name
        ORDER BY rnk
        LIMIT 3"""))
    for r in rows:
        print(r.rnk, r.name, r.cups)
