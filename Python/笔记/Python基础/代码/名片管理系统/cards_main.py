import cards_tools
while True:
    cards_tools.cards_menu()
    action = input("请选择希望执行的操作：")
    print("您选择的操作是【%s】" % action)

    # 1，2，3 针对名片的操作
    if action in ["1", "2", "3"]:
        # 根据用户输入决定后续的操作
        if action == "1":
            cards_tools.add_card()
        elif action == "2":
            cards_tools.show_all()
        elif action == "3":
            cards_tools.search_card()

    # 0 退出系统
    elif action == "0":
        print("欢迎再次使用名片管理系统。")
        break

    # 其他内容输入错误，需要提示用户
    else:
        print("您输入的不正确，请重新选择。")
