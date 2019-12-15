def cards_menu():
    """菜单栏"""
    print("=" * 70)
    print("欢迎进入名片操作系统!")
    print("")
    print("1. 新建名片")
    print("2. 显示全部")
    print("3. 查询名片")
    print("-" * 70)
    print("")
    print("0. 退出系统")
    print("=" * 70)


cards_list = []


def add_card():
    """新增名片"""
    print("-" * 70)
    card_dict = {"name": input("请输入姓名："),
                 "old": input("请输入年龄："),
                 "QQ": input("请输入QQ："),
                 "Email": input("请输入Email：")
                 }
    cards_list.append(card_dict)
    # print(cards_list)
    print("成功添加 %s 的名片。" % card_dict["name"])


def show_all():
    """显示全部名片"""
    if len(cards_list) == 0:
        print("没有任何名片,请先添加名片。")
        return

    # print("姓名\t\t年龄\t\tQQ\t\tEmail")
    for name in ["姓名", "年龄", "QQ", "Email"]:
        print(name, end="\t\t")
    print("")
    print("-" * 70)
    for card_dict in cards_list:
        print("%s\t\t%s\t\t%s\t\t%s" % (
            card_dict["name"], card_dict["old"], card_dict["QQ"], card_dict["Email"]))
    print("")


def search_card():
    """查询名片"""
    print("-" * 70)
    print("查询名片")
    card_name = input("请输入您要查询的名片：")
    print("姓名\t\t年龄\t\tQQ\t\tEmail")
    print("-" * 70)
    for card_dict in cards_list:
        if card_dict["name"] == card_name:
            print("%s\t\t%s\t\t%s\t\t%s" % (
                card_dict["name"], card_dict["old"], card_dict["QQ"], card_dict["Email"]))
            print("-" * 70)

            action_str = input("请输入您的操作：1. 更改 2. 删除 0. 返回上级菜单 ：")
            if action_str == "1":
                card_dict["name"] = input_message(card_dict["name"], "请输入姓名：")
                card_dict["old"] = input_message(card_dict["old"], "请输入年龄：")
                card_dict["QQ"] = input_message(card_dict["QQ"], "请输入QQ：")
                card_dict["Email"] = input_message(
                    card_dict["Email"], "请输入Email：")
                print("修改名片成功。")
                print("")
            elif action_str == "2":
                cards_list.remove(card_dict)
                print("删除名片成功。")
                print("")

            break

    else:
        print("没有找到 %s 的名片" % card_name)


def input_message(old_value, tip_message):
    """对更改和删除名片的细化"""
    new_value = input(tip_message)
    if len(new_value) > 0:
        return new_value
    else:
        return old_value
