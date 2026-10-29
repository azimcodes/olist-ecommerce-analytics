USE [OlistEcommerce]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 10/20/2026 9:22:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[customer_id] [varchar](32) NOT NULL,
	[customer_unique_id] [varchar](32) NOT NULL,
	[customer_zip_code_prefix] [varchar](5) NOT NULL,
	[customer_city] [varchar](100) NOT NULL,
	[customer_state] [varchar](2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Geolocation]    Script Date: 10/20/2026 9:22:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Geolocation](
	[geolocation_zip_code_prefix] [int] NULL,
	[geolocation_lat] [decimal](10, 7) NULL,
	[geolocation_lng] [decimal](10, 7) NULL,
	[geolocation_city] [varchar](100) NULL,
	[geolocation_state] [varchar](2) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderItems]    Script Date: 10/20/2026 9:22:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderItems](
	[order_id] [varchar](32) NOT NULL,
	[order_item_id] [int] NOT NULL,
	[product_id] [varchar](32) NOT NULL,
	[seller_id] [varchar](32) NOT NULL,
	[shipping_limit_date] [datetime] NULL,
	[price] [decimal](10, 2) NULL,
	[freight_value] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[order_id] ASC,
	[order_item_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderPayments]    Script Date: 10/20/2026 9:22:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderPayments](
	[order_id] [varchar](32) NOT NULL,
	[payment_sequential] [int] NOT NULL,
	[payment_type] [varchar](30) NULL,
	[payment_installments] [int] NULL,
	[payment_value] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[order_id] ASC,
	[payment_sequential] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderReviews]    Script Date: 10/20/2026 9:22:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderReviews](
	[review_id] [varchar](32) NOT NULL,
	[order_id] [varchar](32) NOT NULL,
	[review_score] [int] NULL,
	[review_comment_title] [varchar](255) NULL,
	[review_comment_message] [varchar](max) NULL,
	[review_creation_date] [datetime] NULL,
	[review_answer_timestamp] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 10/20/2026 9:22:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[order_id] [varchar](32) NOT NULL,
	[customer_id] [varchar](32) NOT NULL,
	[order_status] [varchar](30) NULL,
	[order_purchase_timestamp] [datetime] NULL,
	[order_approved_at] [datetime] NULL,
	[order_delivered_carrier_date] [datetime] NULL,
	[order_delivered_customer_date] [datetime] NULL,
	[order_estimated_delivery_date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductCategoryTranslation]    Script Date: 10/20/2026 9:22:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductCategoryTranslation](
	[product_category_name] [varchar](100) NOT NULL,
	[product_category_name_english] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[product_category_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 10/20/2026 9:22:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[product_id] [varchar](32) NOT NULL,
	[product_category_name] [varchar](100) NULL,
	[product_name_lenght] [int] NULL,
	[product_description_lenght] [int] NULL,
	[product_photos_qty] [int] NULL,
	[product_weight_g] [int] NULL,
	[product_length_cm] [int] NULL,
	[product_height_cm] [int] NULL,
	[product_width_cm] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[product_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sellers]    Script Date: 10/20/2026 9:22:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sellers](
	[seller_id] [varchar](32) NOT NULL,
	[seller_zip_code_prefix] [int] NULL,
	[seller_city] [varchar](100) NULL,
	[seller_state] [varchar](2) NULL,
PRIMARY KEY CLUSTERED 
(
	[seller_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Staging_Customers]    Script Date: 10/20/2026 9:22:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Staging_Customers](
	[customer_id] [varchar](100) NULL,
	[customer_unique_id] [varchar](100) NULL,
	[customer_zip_code_prefix] [varchar](100) NULL,
	[customer_city] [varchar](100) NULL,
	[customer_state] [varchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OrderItems]  WITH CHECK ADD FOREIGN KEY([order_id])
REFERENCES [dbo].[Orders] ([order_id])
GO
ALTER TABLE [dbo].[OrderItems]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[Products] ([product_id])
GO
ALTER TABLE [dbo].[OrderItems]  WITH CHECK ADD FOREIGN KEY([seller_id])
REFERENCES [dbo].[Sellers] ([seller_id])
GO
ALTER TABLE [dbo].[OrderPayments]  WITH CHECK ADD FOREIGN KEY([order_id])
REFERENCES [dbo].[Orders] ([order_id])
GO
ALTER TABLE [dbo].[OrderReviews]  WITH CHECK ADD FOREIGN KEY([order_id])
REFERENCES [dbo].[Orders] ([order_id])
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Category] FOREIGN KEY([product_category_name])
REFERENCES [dbo].[ProductCategoryTranslation] ([product_category_name])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Category]
GO
ALTER TABLE [dbo].[OrderReviews]  WITH CHECK ADD CHECK  (([review_score]>=(1) AND [review_score]<=(5)))
GO
