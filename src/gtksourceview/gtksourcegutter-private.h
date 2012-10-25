/*
 * gtksourcegutter.h
 * This file is part of gtksourceview
 *
 * Copyright (C) 2009 - Jesse van den Kieboom
 *
 * gtksourceview is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * gtksourceview is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

#ifndef __GTK_SOURCE_GUTTER_PRIVATE_H__
#define __GTK_SOURCE_GUTTER_PRIVATE_H__

#include "gtksourcegutter.h"

G_BEGIN_DECLS

struct _GtkSourceView;

GtkSourceGutter *gtk_source_gutter_new (struct _GtkSourceView *view,
                                        GtkTextWindowType      type);

G_END_DECLS

#endif /* __GTK_SOURCE_GUTTER_PRIVATE_H__ */

/* vi:ts=8 */
